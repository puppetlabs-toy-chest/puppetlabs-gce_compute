$zonea = 'us-central1-a'

gce_disk { 'test':
  ensure    => present,
  description  => 'Boot disk for test',
  size_gb    => 10,
  zone    => "$zonea",
  source_image  => 'debian-7',
}

gce_instance { 'test':
  ensure    => present,
  description  => 'Basic web node',
  machine_type  => 'n1-standard-1',
  zone    => "$zonea",
  disk    => 'test,boot',
  network    => 'default',

  require    => Gce_disk['test'],

  puppet_master   => "$fqdn",
  puppet_service  => present,
}
