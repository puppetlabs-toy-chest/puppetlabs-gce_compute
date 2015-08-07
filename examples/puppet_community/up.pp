gce_instance { 'puppet-test-community-instance':
  ensure                   => present,
  zone                     => 'us-central1-f',
  description              => "Instance for testing the puppetlabs-gce_compute \
module and the puppet-community.sh startup script",
  startup_script           => 'puppet-community.sh',
  block_for_startup_script => true,
  puppet_master            => 'master-blaster',
  puppet_service           => present,
  puppet_manifest          => "# install apache2 package and serve a page
class examples (\$version = 'latest') {
  package {'apache2':
    ensure => \$version, # Using the class parameter from above
  }
  file {'/var/www/index.html':
    ensure  => present,
    content => 'Pinocchio says hello!',
    require => Package['apache2'],
  }
  service {'apache2':
    ensure  => running,
    enable  => true,
    require => File['/var/www/index.html'],
  }
}
include examples",
  puppet_modules           => [
    'puppetlabs-apache',
    'puppetlabs-stdlib',
    'puppetlabs-concat'
  ],
  puppet_module_repos      => {
    puppetlabs-gce_compute => "git://github.com/puppetlabs/\
puppetlabs-gce_compute",
    puppetlabs-mysql       => 'git://github.com/puppetlabs/puppetlabs-mysql'
  }
}
