define media_wiki_stack($ensure) {

  # need to delete everything the revers order its created in
  if ($ensure == 'absent') {
    Gce_instance["${name}1"] -> Gce_network["${name}"]
    Gce_instance["${name}2"] -> Gce_network["${name}"]
    Gce_instance["${name}1"] -> Gce_disk["${name}disk"]
    Gce_firewall["${name}ssh"] -> Gce_network["${name}"]
    Gce_firewall["${name}http"] -> Gce_network["${name}"]
    Gce_firewall["${name}mysql"] -> Gce_network["${name}"]
    Gce_firewall["${name}icmp"] -> Gce_network["${name}"]
  }

  Gce_instance {
    zone                     => 'us-central1-a',
    machine_type             => 'n1-standard-1',
    image                    => 'projects/debian-cloud/global/images/debian-7-wheezy-v20130723',
    network                  => "${name}",
    block_for_startup_script => true,
    startup_script_timeout   => 300,
  }

  Gce_disk {
    zone    => 'us-central1-a',
  }

  Gce_firewall {
    network     => "${name}",
  }


  gce_network { "${name}":
    ensure      => $ensure,
    description => 'test network',
    gateway     => '10.0.1.1',
    range       => '10.0.1.0/24',
    # reserve =>
  }

  gce_disk { "${name}disk":
    ensure      => $ensure,
    description => 'small test disk',
    size_gb     => '2',
  }

  # TODO understand how to do this properly
  gce_firewall { "${name}ssh":
    ensure      => $ensure,
    description => 'allows incoming tcp traffic on 22',
    allowed     => 'tcp:22',
    # target_tags
    # allowed_tag_sources
    # allowed_ip_sources
    # tags
  }

  gce_firewall { "${name}http":
    ensure      => $ensure,
    description => 'allows incoming tcp traffic on 80',
    allowed     => 'tcp:80',
  }

  gce_firewall { "${name}mysql":
    ensure      => $ensure,
    description => 'allows incoming tcp traffic on 3306',
    allowed     => 'tcp:3306',
  }

  gce_firewall { "${name}icmp":
    ensure      => $ensure,
    description => 'allows incoming icmp traffic on 3306',
    allowed     => 'icmp',
  }

  gce_instance { "${name}1":
    ensure      => $ensure,
    description => 'DB instance',
    disk        => "${name}disk",
    modules     => ['puppetlabs-mysql'],
    module_repos => {
      'git://github.com/bodepd/puppet-mediawiki'      => 'mediawiki',
    },
    ecn_classes     => {
      'mysql::server' => {
        'config_hash' => { 'bind_address' => '0.0.0.0', 'root_password' => 'root_password' }
      },
      'mediawiki::db::access' => { 'host' => '10.0.1.%', 'password' => 'root_password' }
    },
    tags        => [$name, 'one']
    # authorized_ssh_keys
    # external_ip_address
    # internal_ip_address
    # wait_until_running
    # use_compute_key
  }

  gce_instance { "${name}2":
    ensure       => $ensure,
    description  => 'Mediawiki instnace',
    modules      => ['puppetlabs-apache', 'saz-memcached', 'puppetlabs-stdlib', 'puppetlabs-firewall'],
    module_repos => {
      'git://github.com/bodepd/puppet-mediawiki'        => 'mediawiki',
    },
    ecn_classes      => {
      'mediawiki' => {
        # we are passing in this value to tell the classification bash script to replace this with the real value
        'server_name'      => '$gce_external_ip',
        'admin_email'      => 'admin_email@domain.com',
        'install_db'       => false,
        'db_root_password' => 'root_password',
        'instances'        => {
          'dans_wiki' =>
            { 'db_password'        => 'db_pw',
            # this is magical!
              'db_server'          => "Gce_instance[${name}1][internal_ip_address]",
            }
        }
      }
    },
    #tag          => 'two',
    require      => Gce_instance["${name}1"],
  }
}




media_wiki_stack { 'duder':
  ensure => $::ensure
}
#media_wiki_stack { 'myduder':
#  ensure => $::ensure
#}
