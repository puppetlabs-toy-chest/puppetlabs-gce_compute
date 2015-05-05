gce_instance { 'puppet-test-instance':
  ensure => absent,
  zone   => 'us-central1-a'
}
