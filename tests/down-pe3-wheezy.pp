gce_instance { 'pe3-wheezy':
    ensure       => absent,
    zone         => 'us-central1-f',
}
gce_disk { 'pe3-wheezy':
    ensure       => absent,
    zone         => 'us-central1-f',
}
Gce_instance["pe3-wheezy"] -> Gce_disk["pe3-wheezy"]
