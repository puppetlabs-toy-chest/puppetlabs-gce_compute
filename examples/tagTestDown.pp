gce_auth { 'upbeat-airway-600':
}

gce_disk { 'tags-test':
  ensure        => absent,
  zone          => us-central1-a,
}

gce_instance { 'tags-test':
  ensure        => absent,
  zone          => us-central1-a,
}

Gce_instance['tags-test'] -> Gce_disk['tags-test']
