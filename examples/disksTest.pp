gce_auth { 'upbeat-airway-600':
  ensure  => present,
}

gce_disk { 'test-disk1':
  ensure        => present,
  zone          => 'us-central1-a',
  source_image  => 'debian-7',
  size_gb       => 10,
}

gce_instance { 'test-instance1':
  disks         => ['test-disk1,boot'],
  zone          => 'us-central1-a',
  ensure        => present,
  machine_type  => 'n1-standard-1',
  puppet_master => "$fqdn"
}
