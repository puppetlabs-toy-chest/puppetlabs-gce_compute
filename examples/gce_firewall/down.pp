gce_network { 'puppet-test-firewall-network':
  ensure => absent
}

gce_firewall { 'puppet-test-firewall':
  ensure => absent
}
