gce_disk {'test-disk':
  ensure  => present,
  size_gb => 10,
}

gce_auth {'upbeat-airway-600':
  ensure  => present,
}
