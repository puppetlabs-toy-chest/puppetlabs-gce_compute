gce_network { 'puppet-test-instance-network':
  ensure       => present,
  description  => "Network for testing the puppetlabs-gce_compute module instances"
}

gce_instance { 'puppet-test-instance':
  ensure              => present,
  zone                => 'us-central1-a',
  description         => "Instance for testing the puppetlabs-gce_compute module",
  machine_type        => 'f1-micro',
  network             => 'puppet-test-instance-network',
  on_host_maintenance => 'TERMINATE',
  can_ip_forward      => true
}
