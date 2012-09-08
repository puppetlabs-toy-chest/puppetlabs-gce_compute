define test_gce($ensure = present) {

  # need to delete everything the revers order its created in
  if ($ensure == 'absent') {
    Gce_instance["${name}1"] -> Gce_network["${name}network"]
    Gce_instance["${name}2"] -> Gce_network["${name}network"]
    Gce_instance["${name}1"] -> Gce_disk["${name}disk"]
    Gce_firewall["${name}sshfirewall"] -> Gce_network["${name}network"]
    Gce_firewall["${name}httpfirewall"] -> Gce_network["${name}network"]
  }

  Gce_instance {
    zone    => 'us-central1-a',
    machine => 'n1-standard-1',
    image   => 'projects/google/images/ubuntu-12-04-v20120621',
    network => "${name}network",
  }

  Gce_disk {
    zone    => 'us-central1-a',
  }

  gce_network { "${name}network":
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

  gce_firewall { "${name}sshfirewall":
    ensure      => $ensure,
    description => 'allows incoming traffic',
    network     => "${name}network",
    allowed     => 'tcp:22',
    # target_tags
    # allowed_tag_sources
    # allowed_ip_sources
    # tags
  }
  gce_firewall { "${name}httpfirewall":
    ensure      => $ensure,
    description => 'allows incoming traffic',
    network     => "${name}network",
    allowed     => 'tcp:80',
  }

  # need to figure out how to do ssh stuff...
  gce_instance { "${name}1":
    ensure      => $ensure,
    description => 'a test VM',
    disk        => "${name}disk",
    modules     => ['puppetlabs-mysql'],
    classes     => {
      'mysql::server' => { 'bind_address' => '0.0.0.0' }
    },
    #tags        => [$name, 'one']
    # authorized_ssh_keys
    # external_ip_address
    # internal_ip_address
    # wait_until_running
    # use_compute_key
  }

  gce_instance { "${name}2":
    ensure       => $ensure,
    description  => 'another test VM',
    module_repos => {
      'git://github.com/bodepd/puppet-mediawiki' => 'mediawiki'
    },
    classes      => {
      'mediawiki' => {
        'server_name'      => '',
        'admin_email'      => 'admin_email@domain.com',
        'db_root_password' => 'root_password',
        'instances'        => {
          'dans_wiki' =>
            { 'db_password' => 'db_pw', 'db_server' => "Gce_instance[${name}1][external_ip_address]" }
        }
      }
    },
    #tag          => 'two',
    require      => Gce_instance["${name}1"],
  }
}
test_gce { 'duder':
  ensure => absent
}
