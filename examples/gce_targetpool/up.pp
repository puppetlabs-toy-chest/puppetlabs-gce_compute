gce_targetpool { 'puppet-test-target-pool-backup':
  ensure           => present,
  region           => 'us-central1',
  description      => "Target pool for testing the puppetlabs-gce_compute module target pool backup_pool"
}

gce_httphealthcheck { 'puppet-test-target-pool-http-health-check':
  ensure              => present
}

gce_targetpool { 'puppet-test-target-pool':
  ensure           => present,
  region           => 'us-central1',
  description      => "Target pool for testing the puppetlabs-gce_compute module",
  health_check     => 'puppet-test-target-pool-http-health-check',
  session_affinity => 'CLIENT_IP',
  backup_pool      => 'puppet-test-target-pool-backup',
  failover_ratio   => 0.5
}
