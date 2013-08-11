gce_instance { 'pe3-wheezy':
    ensure       => absent,
    zone         => 'us-central1-a',
}
