gce_network { 'puppet-test-bad-network':
  ensure => present,
  range  => 'bad-range'
}
