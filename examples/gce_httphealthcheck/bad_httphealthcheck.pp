gce_httphealthcheck { 'puppet-test-bad-http-health-check':
  ensure              => present,
  unhealthy_threshold => -1
}
