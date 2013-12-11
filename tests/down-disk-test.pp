$zone = 'us-central1-a'

gce_instance { 'min-params':
    ensure                 => absent,
    zone                   => "$zone",
}

gce_disk {'boot-disk':
    ensure                 => absent,
    zone                   => "$zone",
    require                => Gce_instance["sep-disk"],
}

gce_instance { 'sep-disk':
    ensure                 => absent,
    zone                   => "$zone",
}
