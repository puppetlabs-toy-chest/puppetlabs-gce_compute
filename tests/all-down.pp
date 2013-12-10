# manifests/site.pp
gce_disk { 'puppet-disk':
    ensure      => absent,
    zone        => 'us-central1-a',
}
gce_disk { 'www1':
    ensure      => absent,
    zone        => 'us-central1-a',
}
gce_disk { 'www2':
    ensure      => absent,
    zone        => 'us-central1-b',
}
gce_firewall { 'allow-http':
    ensure      => absent,
}
gce_instance { 'www1':
    ensure       => absent,
    zone         => 'us-central1-a',
}
gce_instance { 'www2':
    ensure       => absent,
    zone         => 'us-central1-b',
}
gce_httphealthcheck { 'basic-http':
    ensure       => absent,
}
gce_targetpool { 'www-pool':
    ensure       => absent,
    region       => 'us-central1',
}
gce_forwardingrule { 'www-rule':
    ensure       => absent,
    region       => 'us-central1',
}

Gce_instance["www1", "www2"] -> Gce_disk["www1", "www2", "puppet-disk"]
Gce_forwardingrule["www-rule"] -> Gce_targetpool["www-pool"]
Gce_targetpool["www-pool"] -> Gce_httphealthcheck["basic-http"]
