$zonea = 'us-central1-a'
$zoneb = 'us-central1-b'
$region = 'us-central1'

gce_firewall { 'puppet-firewall':
  ensure => present,
  description => 'Allow HTTP',
  network => 'default',
  allowed => 'tcp:80',
  allowed_ip_sources => '0.0.0.0/0',
}

gce_forwardingrule { 'puppet-rule':
  ensure => present,
  description => 'Forward HTTP to web instances',
  port_range => '80',
  region => "$region",
  target => 'puppet-pool',
}

gce_targetpool { 'puppet-pool':
  ensure => present,
  health_checks => 'puppet-http',
  instances => "$zonea/puppet-agent-1,$zonea/puppet-agent-2,$zoneb/puppet-agent-3,$zoneb/puppet-agent-4",
#instances => "$zonea/puppet-agent-1",
  region => "$region",
}

# Declare load balancer and other resources required by the load balancer
gce_httphealthcheck { 'puppet-http':
  ensure => present,
  require => Gce_instance['puppet-agent-1', 'puppet-agent-2', 'puppet-agent-3', 'puppet-agent-4'],
#require => Gce_instance['puppet-agent-1'],
  description => 'basic http health check',
}

# Create 4 nodes in 2 different zones
gce_disk { 'puppet-agent-1':
  ensure => present,
  description => 'Boot disk for puppet-agent-1',
  size_gb => 10,
  zone => "$zonea",
  source_image => 'debian-7',
}

gce_instance { 'puppet-agent-1':
  ensure => present,
  description => 'Basic web node made with fog',
  machine_type => 'n1-standard-1',
  zone => "$zonea",
  disk => 'puppet-agent-1,boot',
  network => 'default',
  puppet_master => "$fqdn",
  puppet_service => present,
  async_create    => true,
}

gce_disk { 'puppet-agent-2':
  ensure => present,
  description => 'Boot disk for puppet-agent-2',
  size_gb => 10,
  zone => "$zonea",
  source_image => 'debian-7',
}

gce_instance { 'puppet-agent-2':
  ensure => present,
  description => 'Basic web node made with fog',
  machine_type => 'n1-standard-1',
  zone => "$zonea",
  disk => 'puppet-agent-2,boot',
  network => 'default',
  puppet_master => "$fqdn",
  puppet_service => present,
  async_create    => true,
}

gce_disk { 'puppet-agent-3':
  ensure => present,
  description => 'Boot disk for puppet-agent-3',
  size_gb => 10,
  zone => "$zoneb",
  source_image => 'debian-7',
}

gce_instance { 'puppet-agent-3':
  ensure => present,
  description => 'Basic web node made with fog',
  machine_type => 'n1-standard-1',
  zone => "$zoneb",
  disk => 'puppet-agent-3,boot',
  network => 'default',
  puppet_master => "$fqdn",
  puppet_service => present,
  async_create    => true,
}

gce_disk { 'puppet-agent-4':
  ensure => present,
  description => 'Boot disk for puppet-agent-4',
  size_gb => 10,
  zone => "$zoneb",
  source_image => 'debian-7',
}

gce_instance { 'puppet-agent-4':
  ensure => present,
  description => 'Basic web node made with fog',
  machine_type => 'n1-standard-1',
  zone => "$zoneb",
  disks => ['puppet-agent-4,boot'],
  network => 'default',
  puppet_master => "$fqdn",
  puppet_service => present,
  async_create    => true,
}

gce_auth { 'upbeat-airway-600':
  ensure  => present,
}
