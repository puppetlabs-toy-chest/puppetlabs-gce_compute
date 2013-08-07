require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_httphealthcheck).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
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

end
