gce_network { 'puppet-test-instance-network':
  ensure  => absent,
  require => Gce_instance['puppet-test-instance']
}

gce_instance { 'puppet-test-instance':
  ensure => absent,
  zone   => 'us-central1-a'
}
