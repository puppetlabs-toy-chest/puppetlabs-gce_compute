gce_httphealthcheck { 'puppet-test-http-health-check':
  ensure              => present,
  description         => "Http-health-check for testing the \
puppetlabs-gce_compute module",
  check_interval      => 7,
  timeout             => 7,
  healthy_threshold   => 7,
  host                => 'testhost',
  port                => 666,
  request_path        => '/test/path',
  unhealthy_threshold => 7
}
