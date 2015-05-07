gce_network { 'puppet-test-firewall-rule-network':
  ensure       => present,
  description  => "Network for testing the puppetlabs-gce_compute module firewall rules"
}

gce_firewallrule { 'puppet-test-firewall-rule':
  ensure              => present,
  description         => "Firewall rule for testing the puppetlabs-gce_compute module",
  allowed             => ['tcp:1-66', 'udp:1-666'],
  network             => 'puppet-test-firewall-rule-network',
  allowed_ip_sources  => ['192.168.0.0', '192.168.100.0/24'],
  allowed_tag_sources => ['my-allowed-tag1', 'my-allowed-tag2'],
  target_tags         => ['my-target-tag1', 'my-target-tag2']
}
