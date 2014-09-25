require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_httphealthcheck).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  def self.subtype
    superclass.connection.http_health_checks
  end

  def subtype
    self.class.subtype
  end

  def self.parameter_list
    [:check_interval_sec, :check_timeout_sec, :description,
     :healthy_threshold, :host, :port, :request_path,
     :unhealthy_threshold, :async_destory, :async_create]
  end

end
