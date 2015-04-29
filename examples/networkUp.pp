gce_network { 'fog-test-network':
  ensure  => present,
  range   => '10.160.0.0/16',
  gateway => '10.160.0.1',
}
