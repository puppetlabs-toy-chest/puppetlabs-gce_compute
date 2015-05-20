gce_network { 'puppet-test-network':
  ensure      => present,
  description => 'Network for testing the puppetlabs-gce_compute module',
  range       => '192.168.0.0/16'
}
