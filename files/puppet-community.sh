#!/bin/bash
# this script can be used in combination
# with the gce types to install puppet and
# classify the provisioned instances

set -u
set -e

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

  # We need to grab the distro and release in order to populate
  # the apt repo details. We are assuming that the lsb_release command
  # will be available as even puppet evens has it (lsb_base) package as
  # dependancy.

  # Since puppet requires lsb-release I believe this is ok to use for
  # the purpose of distro and release discovery.
  apt-get update
  apt-get -y install lsb-release
  distro=$(lsb_release -i | cut -f 2 | tr "[:upper:]" "[:lower:]")
  release=$(lsb_release -c | cut -f 2)

  # Setup the apt Puppet repository
  cat > /etc/apt/sources.list.d/puppetlabs.list <<EOFAPTREPO
deb http://apt.puppetlabs.com/ ${release} main
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
  cat >/etc/puppet/puppet.conf <<EOFPUPPETCONF
[main]
  logdir     = /var/log/puppet
  rundir     = /var/run/puppet
  vardir     = /var/lib/puppet
  ssldir     = /var/lib/puppet/ssl
  modulepath = /etc/puppet/modules
  certname   = "$1"
EOFPUPPETCONF

  if [ -f /etc/default/puppet ]; then
    cat > /etc/default/puppet <<EOFPUPPETDEFAULT
# Defaults for puppet - sourced by /etc/init.d/puppet

# Start puppet on boot?
START=yes

# Startup options
DAEMON_OPTS=""
EOFPUPPETDEFAULT
  fi
}

function download_modules() {
  if [ ! -n $1 ]; then
    MODULE_LIST=`echo "$1" | sed 's/,/ /g'`
    for i in $MODULE_LIST; do puppet module install --force $i ; done;
  fi
}

function clone_modules() {
  if [ ! -n "$1" ]; then
    pushd /etc/puppet/modules
    MODULE_LIST=`echo "$1" | sed 's/,/ /g'`
    for i in $MODULE_LIST; do
      MODULE=`echo "$1" | sed 's/:/ /g'`
      puppet git clone $i ;
    done;
    popd
  fi
}


function run_puppet_apply() {
  if [ -n "$1" ]; then
    mkdir -p /etc/puppet/manifests
    mkdir -p /etc/puppet/nodes
    echo '' > /etc/puppet/manifests/empty.pp
    echo '#!/bin/bash
      cat /etc/puppet/nodes/$1.yaml' > /etc/puppet/nodes/enc.sh
    chmod a+x /etc/puppet/nodes/enc.sh
    echo "$1" > /etc/puppet/nodes/"$2".yaml
    # yaml terminus does not merge facts, so it failed with puppet
    # apply
    puppet apply --trace --debug --node_terminus=exec --external_nodes=/etc/puppet/nodes/enc.sh /etc/puppet/manifests/empty.pp
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

  PUPPET_CLASSES=$(curl http://metadata.google.internal/0.1/meta-data/attributes/puppet_classes)
  PUPPET_MODULES=$(curl http://metadata.google.internal/0.1/meta-data/attributes/puppet_modules)
  PUPPET_REPOS=$(curl http://metadata.google.internal/0.1/meta-data/attributes/puppet_repos)
  PUPPET_HOSTNAME=$(curl http://metadata.google.internal/0.1/meta-data/hostname)

  install_puppet
  configure_puppet "$PUPPET_HOSTNAME"
  download_modules "$PUPPET_MODULES"
  clone_modules    "$PUPPET_REPOS"
  run_puppet_apply "$PUPPET_CLASSES"
  echo "Puppet installation finished!"
  exit 0
}

provision_puppet
