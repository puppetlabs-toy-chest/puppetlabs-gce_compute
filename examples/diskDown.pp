gce_disk { 'simple-disk':
  ensure => absent,
  zone   => 'us-central1-a'
}

gce_disk { 'complex-disk':
  ensure  => absent,
  zone    => 'us-central1-a'
}
