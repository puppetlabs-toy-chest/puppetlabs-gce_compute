gce_disk { 'carl':
  ensure        => absent,
  zone          => 'us-central1-b',
}

gce_instance { 'carl':
  ensure          => absent,
  zone            => 'us-central1-b',
}

gce_auth {'upbeat-airway-600':
  ensure  => present,
}

Gce_instance['carl'] -> Gce_disk['carl']
