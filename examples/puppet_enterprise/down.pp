gce_instance { 'puppet-test-enterprise-master-instance':
  ensure => absent,
  zone   => 'us-central1-f'
}

gce_instance { 'puppet-test-enterprise-agent-instance':
  ensure => absent,
  zone   => 'us-central1-f'
}
