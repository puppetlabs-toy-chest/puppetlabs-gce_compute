gce_network { 'puppet-test-firewall-rule-network':
  ensure => absent
}

gce_firewallrule { 'puppet-test-firewall-rule':
  ensure => absent
}
