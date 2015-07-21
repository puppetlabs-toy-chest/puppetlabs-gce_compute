# install apache2 package and serve a page
class examples ($version = 'latest') {
  package {'apache2':
    ensure => $version, # Using the class parameter from above
  }
  file {'/var/www/index.html':
    ensure  => present,
    content => 'Pinocchio says hello!',
    require => Package['apache2'],
  }
  service {'apache2':
    ensure  => running,
    enable  => true,
    require => File['/var/www/index.html'],
  }
}
include examples
