require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_httphealthcheck).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  commands :gcloud => "gcloud"

  def gcloud_resource_arg
    'http-health-checks'
  end

  def gcloud_optional_args
    {:check_interval_sec => '--check-interval',
     :check_timeout_sec => '--timeout',
     :description => '--description',
     :healthy_threshold => '--healthy-threshold',
     :host => '--host',
     :port => '--port',
     :request_path => '--request-path',
     :unhealthy_threshold => '--unhealthy-threshold'}
  end
end
