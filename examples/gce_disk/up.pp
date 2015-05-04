gce_disk { 'puppet-test-disk':
  ensure       => present,
  zone         => 'us-central1-a',
  size_gb      => 11,
  description  => "Disk for testing the puppetlabs-gce_compute module",
  source_image => 'coreos'
}
