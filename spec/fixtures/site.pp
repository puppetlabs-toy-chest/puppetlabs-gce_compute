# manifests/site.pp
gce_network { 'puppet-network':
  ensure      => present,
  description => 'network created from puppet',
  range       => '10.240.8.0/24',
  gateway     => '10.240.8.1',
}
gce_disk { 'puppet-disk-small':
  ensure      => present,
  description => 'small test disk created with puppet',
  zone        => 'us-central2-a',
  size_gb     => '8',
}
gce_firewall { 'puppet-firewall':
  ensure      => present,
  description => 'allows incoming finger connections',
  network     => 'puppet-network',
  allowed     => 'tcp:79',
}
gce_instance { 'puppet-instance-01':
  ensure       => present,
  description  => 'a test VM created with puppet',
  disk         => 'puppet-disk-small',
  network      => 'puppet-network',
  machine_type => 'n1-standard-1',
  image        => 'projects/centos-cloud/global/images/centos-6-v20130731',
  zone         => 'us-central2-a',
  tags         => [test, 'one']
}
