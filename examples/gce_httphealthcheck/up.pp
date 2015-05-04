gce_httphealthcheck { 'puppet-test-http-health-check':
  ensure              => present,
  check_interval_sec  => 7,
  check_timeout_sec   => 7,
  description         => "Http-health-check for testing the puppetlabs-gce_compute module",
  healthy_threshold   => 7,
  host                => 'testhost',
  port                => 666,
  request_path        => '/test/path',
  unhealthy_threshold => 7
}
