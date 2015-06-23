gce_network { 'puppet-test-firewall-rule-network':
  ensure      => present,
  description => "Network for testing the puppetlabs-gce_compute module \
firewall rules"
}

gce_firewallrule { 'puppet-test-firewall-rule':
  ensure        => present,
  description   => "Firewall rule for testing the puppetlabs-gce_compute \
module",
  allow         => ['tcp:1-66', 'udp:1-666'],
  network       => 'puppet-test-firewall-rule-network',
  source_ranges => ['192.168.0.0', '192.168.100.0/24'],
  source_tags   => ['my-allowed-tag1', 'my-allowed-tag2'],
  target_tags   => ['my-target-tag1', 'my-target-tag2']
}
