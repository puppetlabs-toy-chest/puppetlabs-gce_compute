$zone = 'us-central1-a'

gce_instance { 'min-params':
    ensure                 => present,
    machine_type           => 'n1-standard-1',
    zone                   => "$zone",
    image                  => 'projects/debian-cloud/global/images/debian-7-wheezy-v20131120',
}

gce_disk {'boot-disk':
    ensure                 => present,
    zone                   => "$zone",
    source_image           => 'projects/debian-cloud/global/images/debian-7-wheezy-v20131120',
}

gce_instance { 'sep-disk':
    ensure                 => present,
    machine_type           => 'n1-standard-1',
    zone                   => "$zone",
    disk                   => 'boot-disk,boot',
    require                => Gce_disk["boot-disk"],
}
