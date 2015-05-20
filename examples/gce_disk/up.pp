gce_disk { 'puppet-test-disk':
  ensure      => present,
  zone        => 'us-central1-a',
  description => 'Disk for testing the puppetlabs-gce_compute module',
  size        => 11,
  image       => 'coreos'
}
