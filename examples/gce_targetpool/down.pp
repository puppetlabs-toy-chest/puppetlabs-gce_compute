gce_targetpool { 'puppet-test-target-pool-backup':
  ensure  => absent,
  region  => 'us-central1',
  require => Gce_targetpool['puppet-test-target-pool']
}

gce_httphealthcheck { 'puppet-test-target-pool-http-health-check':
  ensure  => absent,
  require => Gce_targetpool['puppet-test-target-pool']
}

gce_instance { 'puppet-test-target-pool-instance':
  ensure  => absent,
  zone    => 'us-central1-f',
  require => Gce_targetpool['puppet-test-target-pool']
}

gce_targetpool { 'puppet-test-target-pool':
  ensure => absent,
  region => 'us-central1'
}
