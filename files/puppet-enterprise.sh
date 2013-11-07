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
  if [ -n $1 ]; then
    MODULE_LIST=`echo "$1" | sed 's/,/ /g'`
    for i in $MODULE_LIST; do puppet module install --force $i ; done;
  fi
}

function install_puppetagent () {
  case ${breed} in
    "redhat")
      ntpdate -u metadata.google.internal
      curl -s http://$PUPPET_PE_MASTER/el.bash | /bin/bash ;;
    "debian")
      curl -s http://$PUPPET_PE_MASTER/deb.bash | /bin/bash ;;
  esac
}

function clone_modules() {
  if [ -n "$1" ]; then
    #get git, regardless of platform
    apt-get install -y git-core 2>/dev/null || yum install -y git 2>/dev/null
    pushd /etc/puppetlabs/puppet/modules
    MODULE_LIST=`echo "$1" | sed 's/,/ /g'`
    for i in $MODULE_LIST; do
      MODULE=`echo "$i" | sed 's/#/ /'`
      if [ ! -d `echo $MODULE | cut -d' ' -f2` ]; then
        git clone $MODULE ;
      fi
    done;
    popd
  fi
}

#delete me, testing provisioing
function prep_master () {
  # speed up agent checkin, autosign our domain, include pe_mcollective
  echo "*.$(facter -p domain)" > /etc/puppetlabs/puppet/autosign.conf
  curl -s https://gist.github.com/mrzarquon/7330341/raw/fcacaef442845cfd6fe4eba20c925d013eac8e7c/gistfile1.txt > /etc/puppetlabs/puppet/manifests/site.pp

  #get git, regardless of platform
  #apt-get install -y git-core 2>/dev/null || yum install -y git 2>/dev/null

  # install pe_repo for fast agent installs
  git clone https://github.com/mrzarquon/mrzarquon-pe_repo /etc/puppetlabs/puppet/modules/pe_repo
  /opt/puppet/bin/puppet module install nanliu-staging
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production nodeclass:add['pe_repo','skip']
  /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:addclass[`hostname -f`,'pe_repo']
  /opt/puppet/bin/puppet agent -t
}

function classify_master () {
  declare -a class_array=($PUPPET_PE_CLASSES)
  for class in ${class_array[@]}; do
    /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production nodeclass:add["${class}",'skip']
    /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production node:addclass[`hostname -f`,"${class}"]
  done
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
  PUPPET_CLASSES=$(curl -fs $MD/attributes/puppet_classes)
  PUPPET_MANIFEST=$(curl -fs $MD/attributes/puppet_manifest)
  PUPPET_MODULES=$(curl -fs $MD/attributes/puppet_modules)
  PUPPET_REPOS=$(curl -fs $MD/attributes/puppet_repos)
  PUPPET_HOSTNAME=$(curl -fs $MD/hostname)
  PUPPET_PE_ROLE=$(curl -fs $MD/attributes/pe_role)
  PUPPET_PE_VERSION=$(curl -fs $MD/attributes/pe_version)
  PUPPET_PE_CONSOLEADMIN=$(curl -fs $MD/attributes/pe_consoleadmin)
  PUPPET_PE_CONSOLEPWD=$(curl -fs $MD/attributes/pe_consolepwd)
  PUPPET_PE_MASTER=$(curl -fs $MD/attributes/pe_master)
  #turn csl in metadata to spaces for array
  PUPPET_PE_CLASSES=$(curl -fs $MD/attributes/pe_classes | tr "," " ")
  # BEGIN HACK
  #
  # This is a pretty awful hack, but I did not really understand a better way to do it.
  # The problem is that applications may need to specify facts or other system specific information
  # as a part of the classifaction process. I this case, I need to be able to figure out my own internal
  # and external ip addresses.
  # I am going to just pass in these specific things as variables in the puppetcode and parse them out here.
  # Eventually, I may want to do some kind of a fact lookup
  GCE_EXTERNAL_IP=$(curl -fs $MD/network-interfaces/0/access-configs/0/external-ip)
  #GCE_EXTERNAL_IP=$(curl -fs http://bot.whatismyipaddress.com)
  GCE_INTERNAL_IP=$(curl -fs $MD/network-interfaces/0/ip)
  #GCE_INTERNAL_IP=$(ifconfig eth0 |grep "inet addr:" | cut -c21-34)
  PUPPET_CLASSES=$(echo "$PUPPET_CLASSES" | sed -e "s/\$gce_external_ip/$GCE_EXTERNAL_IP/" -e "s/\$gce_internal_ip/$GCE_INTERNAL_IP/")
  PUPPET_MANIFEST=$(echo "$PUPPET_MANIFEST" | sed -e "s/\$gce_external_ip/$GCE_EXTERNAL_IP/" -e "s/\$gce_internal_ip/$GCE_INTERNAL_IP/")
  # END HACK
  
  if [ $PUPPET_PE_ROLE = 'master' ]; then
    install_puppetmaster
    #prep_master
    download_modules "$PUPPET_MODULES"
    clone_modules    "$PUPPET_REPOS"
    classify_master
  else
    install_puppetagent
  fi

  /opt/puppet/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --no-splay
  echo $? > $RESULTS_FILE
  echo "Puppet installation finished!"
  exit 0
}

provision_puppet
