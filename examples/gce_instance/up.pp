gce_instance { 'puppet-test-instance':
  ensure       => present,
  zone         => 'us-central1-a',
  description  => "Instance for testing the puppetlabs-gce_compute module"
}
