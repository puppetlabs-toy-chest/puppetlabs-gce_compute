gce_auth { 'intense-slice-603':
  ensure        => present,
}

gce_disk { 'carl':
  ensure        => present,
  description   => 'Boot disk for carl',
  size_gb       => 10,
  zone          => 'us-central1-b',
  source_image  => 'debian-7-wheezy-v20140606',
}

gce_instance { 'carl':
  ensure          => present,
  description     => 'Basic web node',
  machine_type    => 'n1-standard-1',
  disk            => 'carl,boot',
  network         => 'default',
  zone => 'zone',
  require         => Gce_disk['carl'],

  puppet_master   => "$fqdn",
  puppet_service  => present,
}

gce_auth { 'upbeat-airway-600':
  ensure  => present,
}
