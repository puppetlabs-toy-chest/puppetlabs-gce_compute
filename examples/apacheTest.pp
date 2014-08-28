gce_disk { 'apache-test':
  ensure        => present,
  description   => 'Boot disk for apache-test',
  size_gb       => 10,
  zone          => 'us-central1-b',
  source_image  => 'debian-7-wheezy-v20140606',
}

gce_instance { 'apache-test':
  ensure          => present,
  description     => 'Basic web node',
  machine_type    => 'n1-standard-1',
  zone            => 'us-central1-b',
  disk            => 'apache-test,boot',
  network         => 'default',

  require         => Gce_disk['apache-test'],

  puppet_master   => "$fqdn",
  puppet_service  => present,
}
