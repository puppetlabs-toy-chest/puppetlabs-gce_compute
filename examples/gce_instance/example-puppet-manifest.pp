class apache ($version = "latest") {
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
include apache
