gce_network { 'puppet-test-firewall-rule-network':
  ensure  => absent,
  require => Gce_firewallrule['puppet-test-firewall-rule']
}

gce_firewallrule { 'puppet-test-firewall-rule':
  ensure => absent
}
