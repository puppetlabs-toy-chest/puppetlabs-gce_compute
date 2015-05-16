gce_instance { 'puppet-test-community-instance':
  ensure                   => present,
  zone                     => 'us-central1-a',
  description              => "Instance for testing the puppetlabs-gce_compute module and the puppet-community.sh startup script",
  startup_script           => 'puppet-community.sh',
  block_for_startup_script => true,
  puppet_master            => 'master-blaster',
  puppet_modules           => ['puppetlabs-mysql', 'puppetlabs-apache', 'puppetlabs-stdlib', 'puppetlabs-concat']
}
