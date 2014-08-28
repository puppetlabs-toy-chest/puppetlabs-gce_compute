node /^puppet-agent-\d+/ {
  class { 'apache': }

  include apache::mod::headers

  file {"/var/www/index.html":
    ensure  => present,
    content => template("apache/index.html.erb"),
    require => Class["apache"],
  }
}
