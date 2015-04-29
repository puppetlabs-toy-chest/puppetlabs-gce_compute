gce_instance { 'test-multi-disk':
  ensure          => absent,
  zone            => us-central1-a,
}

gce_disk { 'multi-disk-1':
  ensure        => absent,
  zone          => us-central1-a,
}

gce_disk { 'multi-disk-2':
  ensure        => absent,
  zone          => us-central1-a,
}

gce_disk { 'multi-disk-3':
  ensure        => absent,
  zone          => us-central1-a,
}

gce_auth { 'upbeat-airway-600':
}

Gce_instance['test-multi-disk'] -> Gce_disk['multi-disk-1', 'multi-disk-2', 'multi-disk-3']
