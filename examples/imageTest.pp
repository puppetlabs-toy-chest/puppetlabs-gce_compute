$zonea = 'us-central1-a'

gce_disk { 'joe':
  ensure  => present,
  size_gb  => 10,
  zone    => "$zonea",
  source_image  => 'debian-7',
}

gce_disk { 'sam':
  ensure  => present,
  size_gb  => 10,
  zone    => "$zonea",
  source_image  => 'debian-7-wheezy-v20140606',
}
