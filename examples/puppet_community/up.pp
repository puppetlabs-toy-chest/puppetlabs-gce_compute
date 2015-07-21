gce_instance { 'puppet-test-community-instance':
  ensure                   => present,
  zone                     => 'us-central1-f',
  description              => "Instance for testing the puppetlabs-gce_compute \
module and the puppet-community.sh startup script",
  startup_script           => 'puppet-community.sh',
  block_for_startup_script => true,
  puppet_master            => 'master-blaster',
  puppet_service           => present,
  puppet_manifest          => '../examples/manifests/init.pp',
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
