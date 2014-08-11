gce_firewall { 'fog-test-firewall':
  ensure              => present,
  allowed             => 'tcp:80-100, tcp:ssh, udp:, sctp:ssh-time,6:8080',
  network             => 'default',
  allowed_ip_sources  => '0.0.0.0/0',
}
