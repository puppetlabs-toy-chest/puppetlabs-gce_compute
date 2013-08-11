gce_instance { 'pe3-wheezy':
    ensure       => present,
    description  => 'web server',
    machine_type => 'n1-standard-1',
    zone         => 'us-central1-a',
    network      => 'default',
    image        => 'projects/debian-cloud/global/images/debian-7-wheezy-v20130723',
    tags         => ['web'],
    modules      => ['puppetlabs-mysql', 'puppetlabs-apache', 'puppetlabs-stdlib', 'ripienaar-concat'],
    ecn_classes  => {'mysql::server' => { 'config_hash' => { 'bind_address' => '127.0.0.1' }},
                     'apache' => nil,
                     'mysql::python' => nil
                    },
}
