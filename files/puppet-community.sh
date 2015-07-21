#!/bin/bash
# this script can be used in combination with the gce types to install
# puppet and classify the provisioned instances

RESULTS_FILE='/tmp/puppet_bootstrap_output'

function check_exit_status() {
  if [ ! -f $RESULTS_FILE ]; then
    echo '1' > $RESULTS_FILE
  fi
}

trap check_exit_status INT TERM EXIT

function fedora_repo() {
  cat >/etc/yum.repos.d/puppet.repo <<'EOFYUMREPO'
[puppetlabs]
name = Puppetlabs
baseurl = http://yum.puppetlabs.com/fedora/f$releasever/products/$basearch/
gpgcheck = 1
enabled = 1
gpgkey = http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
EOFYUMREPO
}

function el_repo() {
  cat >/etc/yum.repos.d/puppet.repo <<'EOFYUMREPO'
[puppetlabs]
name = Puppetlabs
baseurl = http://yum.puppetlabs.com/el/$releasever/products/$basearch/
gpgcheck = 1
enabled = 1
gpgkey = http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
[puppetlabs-deps]
name = Puppetlabs Dependencies
baseurl = http://yum.puppetlabs.com/el/$releasever/dependencies/$basearch/
gpgcheck = 1
enabled = 1
gpgkey = http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
EOFYUMREPO
}

function rpm_install() {
  # Setup the yum Puppet repository
  rpm -q fedora-release && fedora_repo || el_repo

  # Install Puppet from yum.puppetlabs.com
  yum install -y puppet git
}

function apt_install() {
  # Download and install the puppetlabs apt public
  apt-key adv --recv-key --keyserver pool.sks-keyservers.net 4BD6EC30

  distro=$(lsb_release -si | tr "[:upper:]" "[:lower:]")
  release=$(lsb_release -sc)

  # Setup the apt Puppet repository
  cat > /etc/apt/sources.list.d/puppetlabs.list <<EOFAPTREPO
deb http://apt.puppetlabs.com/ ${release} main dependencies
EOFAPTREPO
  apt-get update
  # Install Puppet from Debian repositories
  apt-get -y install puppet git
}

function install_puppet() {
  case ${breed} in
    "redhat")
      rpm_install ;;
    "debian")
      apt_install ;;
  esac
}

function configure_puppet() {
  local certname="$1"
  local master="$2"
  local service="$3"

  cat >/etc/puppet/puppet.conf <<EOFPUPPETCONF
[main]
  server     = "${master}"
  logdir     = /var/log/puppet
  rundir     = /var/run/puppet
  vardir     = /var/lib/puppet
  ssldir     = /var/lib/puppet/ssl
  modulepath = /etc/puppet/modules
  certname   = "${certname}"
EOFPUPPETCONF

  local start="no"
  if [[ $service == 'present' ]]; then
    start="yes"
  fi
  if [ -f /etc/default/puppet ]; then
    cat > /etc/default/puppet <<EOFPUPPETDEFAULT
# Defaults for puppet - sourced by /etc/init.d/puppet

# Start puppet on boot?
START=${start}

# Startup options
DAEMON_OPTS=""
EOFPUPPETDEFAULT
  fi
}

function download_modules() {
  if [ -n "$1" ]; then
    for i in $1; do puppet module install --force $i ; done;
  fi
}

function clone_modules() {
  if [ -n "$1" ]; then
    pushd /etc/puppet/modules
    for i in $1; do
      MODULE=`echo "$i" | sed 's/#/ /'`
      if [ ! -d `echo $MODULE | cut -d' ' -f2` ]; then
        git clone $MODULE ;
      fi
    done;
    popd
  fi
}

function run_manifest_apply() {
  if [ -n "$1" ]; then
    mkdir -p /etc/puppet/manifests
    echo "$1" > /etc/puppet/manifests/"$2".pp
    puppet apply --trace --debug /etc/puppet/manifests/"$2".pp
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
  PUPPET_MASTER=$(curl -fs $MD/attributes/puppet_master)
  PUPPET_SERVICE=$(curl -fs $MD/attributes/puppet_service)
  PUPPET_CLASSES=$(curl -fs $MD/attributes/puppet_classes)
  PUPPET_MANIFEST=$(curl -fs $MD/attributes/puppet_manifest)
  PUPPET_MODULES=$(curl -fs $MD/attributes/puppet_modules)
  PUPPET_REPOS=$(curl -fs $MD/attributes/puppet_module_repos)
  PUPPET_HOSTNAME=$(curl -fs $MD/hostname)

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

  install_puppet
  configure_puppet "$PUPPET_HOSTNAME" "$PUPPET_MASTER" "$PUPPET_SERVICE"
  download_modules "$PUPPET_MODULES"
  clone_modules    "$PUPPET_REPOS"
  run_manifest_apply "$PUPPET_MANIFEST" "$PUPPET_HOSTNAME"

  if [[ ${PUPPET_SERVICE} == 'present' ]]; then
    puppet resource service puppet ensure=running enable=true
  fi

  echo $? > $RESULTS_FILE
  echo "Puppet installation finished!"
  exit 0
}

provision_puppet
