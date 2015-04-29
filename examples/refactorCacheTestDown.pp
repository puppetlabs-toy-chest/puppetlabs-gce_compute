$zonea = 'us-central1-a'
$zoneb = 'us-central1-b'
$region = 'us-central1'

gce_firewall { 'test-firewall':
  ensure => absent,
  async_destroy => true,
}

# Declare load balancer and other resources required by the load balancer
gce_httphealthcheck { 'test-http':
  ensure => absent,
  async_destroy => true,
}

gce_targetpool { 'test-pool':
  ensure => absent,
}

gce_forwardingrule { 'test-rule':
  ensure => absent,
}

# Create 4 nodes in 2 different zones
gce_disk { 'test-child-1':
  ensure => absent,
  zone => "$zonea",
  async_destroy => true,
}

gce_instance { 'test-child-1':
  ensure => absent,
  zone => "$zonea",
}

gce_disk { 'test-child-2':
  ensure => absent,
  zone => "$zonea",
  async_destroy => true,
}

gce_instance { 'test-child-2':
  ensure => absent,
  zone => "$zonea",
}

gce_disk { 'test-child-3':
  ensure => absent,
  zone => "$zoneb",
  async_destroy => true,
}

gce_instance { 'test-child-3':
  ensure => absent,
  zone => "$zoneb",
}

gce_disk { 'test-child-4':
  ensure => absent,
  zone => "$zoneb",
  async_destroy => true,
}

gce_instance { 'test-child-4':
  ensure => absent,
  zone => "$zoneb",
}

Gce_instance['test-child-1', 'test-child-2', 'test-child-3', 'test-child-4'] -> Gce_disk['test-child-1', 'test-child-2', 'test-child-3', 'test-child-4']
Gce_forwardingrule['test-rule'] -> Gce_targetpool['test-pool']
Gce_targetpool['test-pool'] -> Gce_httphealthcheck['test-http']
