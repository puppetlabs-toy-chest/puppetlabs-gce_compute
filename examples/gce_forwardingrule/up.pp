gce_targetpool { 'puppet-test-forwarding-rule-target-pool':
  ensure      => present,
  region      => 'us-central1',
  description => 'Target pool for testing the puppetlabs-gce_compute module forwarding rule'
}

gce_forwardingrule { 'puppet-test-forwarding-rule':
  ensure      => present,
  region      => 'us-central1',
  description => 'Forwarding rule for testing the puppetlabs-gce_compute module',
  ip_protocol => 'UDP',
  port_range  => '1-66',
  target_pool => 'puppet-test-forwarding-rule-target-pool'
}
