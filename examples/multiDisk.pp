gce_instance { 'test-multi-disk':
  ensure          => present,
  machine_type    => 'n1-standard-1',
  zone            => 'us-central1-a',
  disks           => ['multi-disk-2', 'multi-disk-3', 'multi-disk-1, boot'],
  puppet_master   => "$fqdn",
  puppet_service  => present,
}

gce_disk { 'multi-disk-1':
  ensure        => present,
  zone          => us-central1-a,
  source_image  => debian-7,
  size_gb       => 10,
}

gce_disk { 'multi-disk-2':
  ensure        => present,
  zone          => us-central1-a,
  size_gb       => 50,
}

gce_disk { 'multi-disk-3':
  ensure        => present,
  zone          => us-central1-a,
  size_gb       => 100,
}

gce_auth { 'upbeat-airway-600':
}
