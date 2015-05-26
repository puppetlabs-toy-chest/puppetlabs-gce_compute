require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_httphealthcheck).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  confine :gcloud_compatible_version => true
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'http-health-checks'
  end

  def gcloud_optional_create_args
    {:description => '--description',
     :check_interval => '--check-interval',
     :timeout => '--timeout',
     :healthy_threshold => '--healthy-threshold',
     :host => '--host',
     :port => '--port',
     :request_path => '--request-path',
     :unhealthy_threshold => '--unhealthy-threshold'}
  end
end
