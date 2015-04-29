gce_auth { 'intense-slice-603':
  ensure => present
}
gce_disk { 'matthew':
  ensure        => present,
  description   => 'Boot disk for matthew',
  size_gb       => 10,
  zone          => 'us-central1-b',
  source_image  => 'debian-7-wheezy-v20140606',
}
gce_disk { 'zach':
  ensure        => present,
  description   => 'Boot disk for zach',
  size_gb       => 10,
  zone          => 'us-central1-b',
   source_image  => 'debian-7-wheezy-v20140606',
 }
gce_instance { 'matthew':
   ensure          => present,
   description     => 'Basic web node',
   machine_type    => 'n1-standard-1',
   zone            => 'us-central1-b',
   disk            => 'matthew,boot',
   network         => 'default',
 
   require         => Gce_disk['matthew'],
 
    puppet_master   => "$fqdn",
    puppet_service  => present,
  }
gce_instance { 'zach':
  ensure          => present,
  description     => 'Basic web node',
   machine_type    => 'n1-standard-1',
  zone            => 'us-central1-b',
  disk            => 'zach,boot',
  network         => 'default',

  require         => Gce_disk['zach'],

  puppet_master   => "$fqdn",
  puppet_service  => present,
 }

gce_httphealthcheck { 'basic-http-check':
   ensure       => present,
   require      => Gce_instance['matthew', 'zach'],
   description  => 'basic http health check',

}
gce_targetpool { 'www-pool':
    ensure       => present,
    require      => Gce_httphealthcheck['basic-http-check'],
    instances    => 'us-central1-b/zach,us-central1-b/matthew',
    region       => 'us-central1',
}
gce_forwardingrule { 'www-rule':
    ensure       => present,
    require      => Gce_targetpool['www-pool'],
    description  => 'Forward HTTP to web instances',
    port_range   => '80',
    region       => 'us-central1',
}
