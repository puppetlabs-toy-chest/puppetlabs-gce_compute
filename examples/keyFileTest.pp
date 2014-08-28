gce_auth {'upbeat-airway-600':
  client_email  => '....@developer.gserviceaccount.com',
  key_file      => '/path/to/privatekey.p12',
}

gce_disk {'auth-test':
  ensure  => present,
  zone    => us-central1-a,
  size_gb => 5,
}
