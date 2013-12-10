gce_instance { 'pe3-wheezy':
    ensure       => absent,
    zone         => 'us-central1-a',
}
gce_disk { 'pe3-wheezy':
    ensure       => absent,
    zone         => 'us-central1-a',
}
Gce_instance["pe3-wheezy"] -> Gce_disk["pe3-wheezy"]
