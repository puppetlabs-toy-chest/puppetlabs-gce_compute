gce_disk { 'puppet-test-disk':
  ensure      => present,
  zone        => 'us-central1-f',
  description => 'Disk for testing the puppetlabs-gce_compute module',
  size        => 11,
  image       => 'coreos'
}
