gce_disk { 'simple-disk':
  ensure => present,
  zone   => 'us-central1-a'
}

gce_disk { 'complex-disk':
  ensure       => present,
  zone         => 'us-central1-a',
  size_gb      => 10,
  description  => "This is a complicated disk!",
  source_image => 'coreos'
}
