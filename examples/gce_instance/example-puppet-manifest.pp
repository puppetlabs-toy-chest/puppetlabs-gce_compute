# execute 'apt-get update'
exec { 'apt-update':
  command => '/usr/bin/apt-get update'
}

# install apache2 package
package { 'apache2':
  ensure  => installed,
  require => Exec['apt-update']
}

service { 'apache2':
  ensure => running
}
