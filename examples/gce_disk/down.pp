gce_disk { 'puppet-test-disk':
  ensure => absent,
  zone   => 'us-central1-f'
}
