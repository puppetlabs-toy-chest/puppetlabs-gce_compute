gce_instance { 'puppet-test-timeout-instance':
  ensure => absent,
  zone   => 'us-central1-f'
}
