require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcutil'))

Puppet::Type.type(:gce_httphealthcheck).provide(
  :gcutil,
  :parent => Puppet::Provider::Gcutil
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'httphealthcheck'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['check_interval_sec', 'check_timeout_sec', 'description',
     'healthy_threshold', 'host', 'port', 'request_path',
     'unhealthy_threshold']
  end

  def destroy_parameter_list
    []
  end

end
