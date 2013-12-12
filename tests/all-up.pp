# manifests/site.pp

gce_disk { 'puppet-disk':
    ensure      => present,
    description => 'small data disk',
    size_gb     => '2',
    zone        => 'us-central1-a',
}
gce_firewall { 'allow-http':
    ensure      => present,
    network     => 'default',
    description => 'allows incoming HTTP connections',
    allowed     => 'tcp:80',
}
gce_instance { 'www1':
    ensure       => present,
    description  => 'web server',
    disk         => 'puppet-disk',
    machine_type => 'n1-standard-1',
    zone         => 'us-central1-a',
    network      => 'default',
    image        => 'projects/debian-cloud/global/images/debian-7-wheezy-v20131120',
    tags         => ['web'],
    manifest     => 'class apache ($version = "latest") {
      package {"apache2":
        ensure => $version, # Using the class parameter from above
      }
      file {"/var/www/index.html":
        ensure  => present,
        content => "<html>\n<body>\n\t<h2>Hi, this is $gce_external_ip.</h2>\n</body>\n</html>\n",
        require => Package["apache2"],
      }
      service {"apache2":
        ensure => running,
        enable => true,
        require => File["/var/www/index.html"],
      }
    }
    include apache',
}
gce_instance { 'www2':
    ensure       => present,
    description  => 'web server',
    machine_type => 'n1-standard-1',
    zone         => 'us-central1-b',
    network      => 'default',
    image        => 'projects/debian-cloud/global/images/debian-7-wheezy-v20131120',
    tags         => ['web'],
    manifest     => 'class apache ($version = "latest") {
      package {"apache2":
        ensure => $version, # Using the class parameter from above
      }
      file {"/var/www/index.html":
        ensure  => present,
        content => "<html>\n<body>\n\t<h2>Hi, this is $gce_external_ip.</h2>\n</body>\n</html>\n",
        require => Package["apache2"],
      }
      service {"apache2":
        ensure => running,
        enable => true,
        require => File["/var/www/index.html"],
      }
    }
    include apache',
}
gce_httphealthcheck { 'basic-http':
    ensure       => present,
    require      => Gce_instance['www1', 'www2'],
    description  => 'basic http health check',
}
gce_targetpool { 'www-pool':
    ensure       => present,
    require      => Gce_httphealthcheck['basic-http'],
    health_checks => 'basic-http',
    instances    => 'us-central1-a/www1,us-central1-b/www2',
    region       => 'us-central1',
}
gce_forwardingrule { 'www-rule':
    ensure       => present,
    require      => Gce_targetpool['www-pool'],
    description  => 'Forward HTTP to web instances',
    port_range   => '80',
    region       => 'us-central1',
    target       => 'www-pool',
}
