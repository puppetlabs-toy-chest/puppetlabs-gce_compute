gce_network { 'puppet-test-instance-network':
  ensure       => present,
  description  => "Network for testing the puppetlabs-gce_compute module instances"
}

gce_address { 'puppet-test-instance-address':
  ensure       => present,
  region       => 'us-central1',
  description  => "Address for testing the puppetlabs-gce_compute module instances"
}

gce_instance { 'puppet-test-instance':
  ensure             => present,
  zone               => 'us-central1-a',
  description        => "Instance for testing the puppetlabs-gce_compute module",
  address            => 'puppet-test-instance-address',
  image              => 'coreos',
  machine_type       => 'f1-micro',
  network            => 'puppet-test-instance-network',
  maintenance_policy => 'TERMINATE',
  can_ip_forward     => true,
  tags               => ['tag1','tag2'],
  metadata           => {test-metadata-key => 'test-metadata-value'},
  startup_script     => '../examples/gce_instance/example-startup-script.sh'
}

gce_disk { 'puppet-test-instance-alt-disk':
  ensure       => present,
  zone         => 'us-central1-a',
  description  => "Disk for testing the puppetlabs-gce_compute module instance started from a disk",
  size         => 10,
  image        => 'coreos'
}

gce_instance { 'puppet-test-instance-alt':
  ensure              => present,
  zone                => 'us-central1-a',
  description         => "Instance for testing the puppetlabs-gce_compute module instance alternate options",
  boot_disk           => 'puppet-test-instance-alt-disk'
}
