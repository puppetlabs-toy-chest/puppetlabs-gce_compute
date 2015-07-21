#!/bin/bash
# this script can be used in combination with the gce types to install
# puppet and classify the provisioned instances

RESULTS_FILE='/tmp/puppet_bootstrap_output'
S3_BASE='https://s3.amazonaws.com/pe-builds/released/'

function check_exit_status() {
  if [ ! -f $RESULTS_FILE ]; then
    echo '1' > $RESULTS_FILE
  fi
}

trap check_exit_status INT TERM EXIT

function write_masteranswers() {
  cat > /opt/masteranswers.txt << ANSWERS
q_all_in_one_install=y
q_backup_and_purge_old_configuration=n
q_backup_and_purge_old_database_directory=n
q_database_host=localhost
q_database_install=y
q_install=y
q_pe_database=y
q_puppet_cloud_install=y
q_puppet_enterpriseconsole_auth_password=$PUPPET_PE_CONSOLEPWD
q_puppet_enterpriseconsole_auth_user_email=$PUPPET_PE_CONSOLEADMIN
q_puppet_enterpriseconsole_httpd_port=443
q_puppet_enterpriseconsole_install=y
q_puppet_enterpriseconsole_master_hostname=$PUPPET_HOSTNAME
q_puppet_enterpriseconsole_smtp_host=localhost
q_puppet_enterpriseconsole_smtp_password=
q_puppet_enterpriseconsole_smtp_port=25
q_puppet_enterpriseconsole_smtp_use_tls=n
q_puppet_enterpriseconsole_smtp_user_auth=n
q_puppet_enterpriseconsole_smtp_username=
q_puppet_symlinks_install=y
q_puppetagent_certname=$PUPPET_HOSTNAME
q_puppetagent_install=y
q_puppetagent_server=$PUPPET_HOSTNAME
q_puppetdb_hostname=$PUPPET_HOSTNAME
q_puppetdb_install=y
q_puppetdb_port=8081
q_puppetmaster_certname=$PUPPET_HOSTNAME
q_puppetmaster_dnsaltnames=$PUPPET_HOSTNAME,puppet
q_puppetmaster_enterpriseconsole_hostname=localhost
q_puppetmaster_enterpriseconsole_port=443
q_puppetmaster_install=y
q_run_updtvpkg=n
q_vendor_packages_install=y
ANSWERS
}

function write_agentanswers() {
  cat > /opt/agentanswers.txt << ANSWERS
q_fail_on_unsuccessful_master_lookup=y
q_install=y
q_puppet_cloud_install=n
q_puppet_enterpriseconsole_install=n
q_puppet_symlinks_install=y
q_puppetagent_certname=$(hostname -f)
q_puppetagent_install=y
q_puppetagent_server=$PUPPET_PE_MASTER
q_puppetca_install=n
q_puppetdb_hostname=
q_puppetdb_install=n
q_puppetdb_port=
q_puppetmaster_install=n
q_vendor_packages_install=y
q_continue_or_reenter_master_hostname=c
q_verify_packages=y
ANSWERS
}

function install_puppetmaster() {
  if [ ! -d /opt/puppet-enterprise ]; then
    mkdir -p /opt/puppet-enterprise
  fi
  if [ ! -f /opt/puppet-enterprise/puppet-enterprise-installer ]; then
    case ${breed} in
      "redhat")
        ntpdate -u metadata.google.internal
        curl -s -o /opt/pe-installer.tar.gz "https://s3.amazonaws.com/pe-builds/released/$PUPPET_PE_VERSION/puppet-enterprise-$PUPPET_PE_VERSION-el-6-x86_64.tar.gz" ;;
      "debian")
        curl -s -o /opt/pe-installer.tar.gz "https://s3.amazonaws.com/pe-builds/released/$PUPPET_PE_VERSION/puppet-enterprise-$PUPPET_PE_VERSION-debian-7-amd64.tar.gz" ;;
    esac
    #Drop installer in predictable location
    tar --extract --file=/opt/pe-installer.tar.gz --strip-components=1 --directory=/opt/puppet-enterprise
  fi
  write_masteranswers
  /opt/puppet-enterprise/puppet-enterprise-installer -a /opt/masteranswers.txt
}

function download_modules() {
  if [ -n "$1" ]; then
    for i in $1; do puppet module install --force $i ; done;
  fi
}

function install_puppetagent () {
  if [ ! -d /opt/puppet-enterprise ]; then
    mkdir -p /opt/puppet-enterprise
  fi
  if [ ! -f /opt/puppet-enterprise/puppet-enterprise-installer ]; then
    case ${breed} in
      "redhat")
        ntpdate -u metadata.google.internal
        curl -s -o /opt/pe-installer.tar.gz "https://s3.amazonaws.com/pe-builds/released/$PUPPET_PE_VERSION/puppet-enterprise-$PUPPET_PE_VERSION-el-6-x86_64.tar.gz" ;;
      "debian")
        curl -s -o /opt/pe-installer.tar.gz "https://s3.amazonaws.com/pe-builds/released/$PUPPET_PE_VERSION/puppet-enterprise-$PUPPET_PE_VERSION-debian-7-amd64.tar.gz" ;;
    esac
    #Drop installer in predictable location
    tar --extract --file=/opt/pe-installer.tar.gz --strip-components=1 --directory=/opt/puppet-enterprise
  fi
  write_agentanswers
  /opt/puppet-enterprise/puppet-enterprise-installer -a /opt/agentanswers.txt
}

function clone_modules() {
  if [ -n "$1" ]; then
    #get git, regardless of platform
    apt-get install -y git-core 2>/dev/null || yum install -y git 2>/dev/null
    pushd /etc/puppetlabs/puppet/modules
    for i in $1; do
      MODULE=`echo "$i" | sed 's/#/ /'`
      if [ ! -d `echo $MODULE | cut -d' ' -f2` ]; then
        git clone $MODULE ;
      fi
    done;
    popd
  fi
}

function provision_puppet() {
  if [ -f /etc/redhat-release ]; then
    export breed='redhat'
  elif [ -f /etc/debian_version ]; then
    export breed='debian'
  else
    echo "This OS is not supported by Puppet Cloud Provisioner"
    exit 1
  fi
  
  # For more on metadata, see https://developers.google.com/compute/docs/metadata
  MD="http://metadata/computeMetadata/v1beta1/instance"
  PUPPET_MODULES=$(curl -fs $MD/attributes/puppet_modules)
  PUPPET_REPOS=$(curl -fs $MD/attributes/puppet_module_repos)
  PUPPET_HOSTNAME=$(curl -fs $MD/hostname)
  PUPPET_PE_ROLE=$(curl -fs $MD/attributes/pe_role)
  PUPPET_PE_VERSION=$(curl -fs $MD/attributes/pe_version)
  PUPPET_PE_CONSOLEADMIN=$(curl -fs $MD/attributes/pe_consoleadmin)
  PUPPET_PE_CONSOLEPWD=$(curl -fs $MD/attributes/pe_consolepwd)
  PUPPET_PE_MASTER=$(curl -fs $MD/attributes/pe_master)
  
  if [ $PUPPET_PE_ROLE = 'master' ]; then
    install_puppetmaster
    #prep_master
    download_modules "$PUPPET_MODULES"
    clone_modules    "$PUPPET_REPOS"
    classify_master
  else
    install_puppetagent
  fi

  if [ $PUPPET_PE_ROLE = 'master' ]; then
    /opt/puppet/bin/puppet agent --onetime --no-daemonize --color=false --verbose
  else
    /opt/puppet/bin/puppet agent --onetime --no-daemonize --color=false --verbose --splay --splaylimit 30 --waitforcert 120
  fi

  echo $? > $RESULTS_FILE
  echo "Puppet installation finished!"
  exit 0
}

provision_puppet
