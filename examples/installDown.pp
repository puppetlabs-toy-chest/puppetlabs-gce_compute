$zonea = 'us-central1-a'

gce_disk { 'test':
  ensure    => absent,
  zone    => "$zonea",
}

gce_instance { 'test':
  ensure    => absent,
  zone    => "$zonea",
}

Gce_instance['test'] -> Gce_disk['test']
