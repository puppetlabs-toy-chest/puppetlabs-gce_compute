$zonea = 'us-central1-a'
$zoneb = 'us-central1-b'
$region = 'us-central1'

gce_firewall { 'test-firewall':
  ensure => present,
  description => 'Allow HTTP',
  network => 'default',
  allowed => 'tcp:80',
  allowed_ip_sources => '0.0.0.0/0',
}

# Declare load balancer and other resources required by the load balancer
gce_httphealthcheck { 'test-http':
  ensure => present,
  require => Gce_instance['test-child-1', 'test-child-2', 'test-child-3', 'test-child-4'],
#require => Gce_instance['test-child-1'],
  description => 'basic http health check',
}

gce_targetpool { 'test-pool':
  ensure => present,
  require => Gce_httphealthcheck['test-http'],
  health_checks => 'test-http',
  instances => "$zonea/test-child-1,$zonea/test-child-2,$zoneb/test-child-3,$zoneb/test-child-4",
#instances => "$zonea/test-child-1",
  region => "$region",
}

gce_forwardingrule { 'test-rule':
  ensure => present,
  require => Gce_targetpool['test-pool'],
  description => 'Forward HTTP to web instances',
  port_range => '80',
  region => "$region",
  target => 'test-pool',
  async_create  => true,
}

# Create 4 nodes in 2 different zones
gce_disk { 'test-child-1':
  ensure => present,
  description => 'Boot disk for test-child-1',
  size_gb => 10,
  zone => "$zonea",
  source_image => 'debian-7-wheezy-v20140606',
}

gce_instance { 'test-child-1':
  ensure => present,
  description => 'Basic web node made with fog',
  machine_type => 'n1-standard-1',
  zone => "$zonea",
  disk => 'test-child-1,boot',
  network => 'default',
  require => Gce_disk['test-child-1'],
  puppet_master => "$fqdn",
  puppet_service => present,
  async_create  => true,
}

gce_disk { 'test-child-2':
  ensure => present,
  description => 'Boot disk for test-child-2',
  size_gb => 10,
  zone => "$zonea",
  source_image => 'debian-7-wheezy-v20140606',
}

gce_instance { 'test-child-2':
  ensure => present,
  description => 'Basic web node made with fog',
  machine_type => 'n1-standard-1',
  zone => "$zonea",
  disk => 'test-child-2,boot',
  network => 'default',
  require => Gce_disk['test-child-2'],
  puppet_master => "$fqdn",
  puppet_service => present,
  async_create  => true,
}

gce_disk { 'test-child-3':
  ensure => present,
  description => 'Boot disk for test-child-3',
  size_gb => 10,
  zone => "$zoneb",
  source_image => 'debian-7-wheezy-v20140606',
}

gce_instance { 'test-child-3':
  ensure => present,
  description => 'Basic web node made with fog',
  machine_type => 'n1-standard-1',
  zone => "$zoneb",
  disk => 'test-child-3,boot',
  network => 'default',
  require => Gce_disk['test-child-3'],
  puppet_master => "$fqdn",
  puppet_service => present,
  async_create  => true,
}

gce_disk { 'test-child-4':
  ensure => present,
  description => 'Boot disk for test-child-4',
  size_gb => 10,
  zone => "$zoneb",
  source_image => 'debian-7-wheezy-v20140606',
}

gce_instance { 'test-child-4':
  ensure => present,
  description => 'Basic web node made with fog',
  machine_type => 'n1-standard-1',
  zone => "$zoneb",
  disk => 'test-child-4,boot',
  network => 'default',
  require => Gce_disk['test-child-4'],
  puppet_master => "$fqdn",
  puppet_service => present,
  async_create  => true,
}

gce_auth { 'upbeat-airway-600':
  ensure  => present,
}
