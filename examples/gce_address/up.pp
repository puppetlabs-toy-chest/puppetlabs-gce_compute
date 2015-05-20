gce_address { 'puppet-test-address':
  ensure      => present,
  region      => 'us-central1',
  description => 'Address for testing the puppetlabs-gce_compute module'
}
