node 'apache-test' {
  package {"apache2":
    ensure => 'latest',
  }
  file {"/var/www/index.html":
    ensure  => present,
    content => "<html>\n<body>\n\t<h2>Hi, this is $hostname.</h2>\n</body>\n</html>\n",
    require => Package["apache2"],
  }
  service {"apache2":
    ensure => running,
    enable => true,
    require => File["/var/www/index.html"],
  }
}
