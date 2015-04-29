$zonea = 'us-central1-a'

gce_disk { 'joe':
  ensure  => present,
  size_gb  => 10,
  zone    => "$zonea",
}
