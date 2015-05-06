gce_network { 'puppet-test-instance-network':
  ensure  => absent,
  require => Gce_instance['puppet-test-instance']
}

gce_instance { 'puppet-test-instance':
  ensure => absent,
  zone   => 'us-central1-a'
}

gce_disk { 'puppet-test-instance-from-disk-disk':
  ensure  => absent,
  zone    => 'us-central1-a',
  require => Gce_instance['puppet-test-instance-from-disk']
}

gce_instance { 'puppet-test-instance-from-disk':
  ensure => absent,
  zone   => 'us-central1-a'
}
