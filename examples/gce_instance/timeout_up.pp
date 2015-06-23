gce_instance { 'puppet-test-timeout-instance':
  ensure                   => present,
  zone                     => 'us-central1-f',
  description              => "Instance for testing the puppetlabs-gce_compute \
module startup script timeout",
  image                    => 'coreos',
  startup_script           => "../examples/gce_instance/\
example-startup-script.sh",
  block_for_startup_script => true,
  startup_script_timeout   => 1
}
