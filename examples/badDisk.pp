$zonea = 'us-central1-a'

gce_auth { 'upbeat-airway-600':
}

gce_disk { 'mary':
  ensure  => present,
  size_gb  => 10,
  zone    => "$zonea",
  source_image  => 'debain-7'
}
