gce_auth {'upbeat-airway-600':
  client_email  => '793012070718-d7hg25tf75lkl8kae21q1fp70qmi6tcb@developer.gserviceaccount.com',
  key_file      => '/home/ashmrtnz/690c8ebf2431e5020e6c1c3aed048c81a470645a-privatekey.p12',
}

gce_disk {'auth-test':
  ensure  => present,
  zone    => us-central1-a,
  size_gb => 5,
}
