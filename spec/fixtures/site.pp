Gce_instance {
  zone         => 'us-central1-a',
  machine_type => 'n1-standard-1',
}

node certname_1 {
  gce_instance { 'one':
    ensure => present,
  }
}

node certname_2 {
  gce_instance { 'two':
    ensure => absent,
  }
}
