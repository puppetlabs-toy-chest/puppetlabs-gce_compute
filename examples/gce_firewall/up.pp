gce_network { 'puppet-test-firewall-network':
  ensure       => present,
  description  => "Network for testing the puppetlabs-gce_compute module firewalls"
}

gce_firewall { 'puppet-test-firewall':
  ensure              => present,
  description         => "Firewall for testing the puppetlabs-gce_compute module",
  allowed             => ['tcp:1-66', 'udp:1-666'],
  network             => 'puppet-test-firewall-network',
  allowed_ip_sources  => ['192.168.0.0', '192.168.100.0/24'],
  allowed_tag_sources => ['my-allowed-tag1', 'my-allowed-tag2'],
  target_tags         => ['my-target-tag1', 'my-target-tag2']
}
