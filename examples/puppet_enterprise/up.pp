gce_instance { 'puppet-test-enterprise-master-instance':
  ensure                   => present,
  zone                     => 'us-central1-f',
  description              => "Instance for testing the puppetlabs-gce_compute \
module and the puppet-enterprise.sh startup script",
  startup_script           => 'puppet-enterprise.sh',
  block_for_startup_script => true,
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
  },
  metadata                 => {
    'pe_role'         => 'master',
    'pe_version'      => '3.3.1',
    'pe_consoleadmin' => 'admin@example.com',
    'pe_consolepwd'   => 'puppetize',
  }
}

gce_instance { 'puppet-test-enterprise-agent-instance':
  ensure                   => present,
  zone                     => 'us-central1-f',
  description              => "Instance for testing the puppetlabs-gce_compute \
module and the puppet-enterprise.sh startup script",
  startup_script           => 'pe-simplified-agent.sh',
  block_for_startup_script => true,
  metadata                 => {
    'pe_role'    => 'agent',
    'pe_master'  => 'puppet-test-enterprise-master-instance',
    'pe_version' => '3.3.1',
  },
  require                  => Gce_instance['puppet-test-enterprise-master-instance']
}
