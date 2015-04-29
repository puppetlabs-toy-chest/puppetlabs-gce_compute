gce_auth { 'upbeat-airway-600':
}

gce_disk { 'tags-test':
  ensure        => present,
  source_image  => debian-7,
  zone          => us-central1-a,
  size_gb       => 10,
}

gce_instance { 'tags-test':
  ensure        => present,
  zone          => us-central1-a,
  tags          => ['test','puppet', ' cool'],
  disks         => ['tags-test,boot'],
  machine_type  => n1-standard-1,
  puppet_master => "$fqdn",
  puppet_service  => present,
  network         => default,
}
