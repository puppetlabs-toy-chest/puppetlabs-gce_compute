Gce_instance {
  auth_file  => '/Users/danbode/.gcutil_auth',
  project_id => 'puppetlabs.com:raiden'
}

gce_instance { 'dan':
  ensure    => present,
}
