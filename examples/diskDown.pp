$zonea = 'us-central1-a'

gce_disk { 'joe':
  ensure  => absent,
  zone    => "$zonea",
}
