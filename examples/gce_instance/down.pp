gce_network { 'puppet-test-instance-network':
  ensure  => absent,
  require => Gce_instance['puppet-test-instance']
}

gce_address { 'puppet-test-instance-address':
  ensure  => absent,
  region  => 'us-central1',
  require => Gce_instance['puppet-test-instance']
}

gce_instance { 'puppet-test-instance':
  ensure => absent,
  zone   => 'us-central1-f'
}

gce_disk { 'puppet-test-instance-alt-disk':
  ensure  => absent,
  zone    => 'us-central1-f',
  require => Gce_instance['puppet-test-instance-alt']
}

gce_instance { 'puppet-test-instance-alt':
  ensure => absent,
  zone   => 'us-central1-f'
}
