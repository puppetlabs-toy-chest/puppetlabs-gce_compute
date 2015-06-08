gce_instance { 'puppet-test-community-instance':
  ensure => absent,
  zone   => 'us-central1-f'
}
