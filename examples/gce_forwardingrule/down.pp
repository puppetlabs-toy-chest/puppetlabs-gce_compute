gce_address { 'puppet-test-forwarding-rule-address':
  ensure  => absent,
  region  => 'us-central1',
  require => Gce_forwardingrule['puppet-test-forwarding-rule']
}

gce_targetpool { 'puppet-test-forwarding-rule-target-pool':
  ensure  => absent,
  region  => 'us-central1',
  require => Gce_forwardingrule['puppet-test-forwarding-rule']
}

gce_forwardingrule { 'puppet-test-forwarding-rule':
  ensure => absent,
  region => 'us-central1'
}
