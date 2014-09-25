require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_network).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  def self.subtype
    superclass.connection.networks
  end

  def subtype
    self.class.subtype
  end

  def self.parameter_list
    [:gateway, :description, :range, :async_destory]
  end

  # remap puppet vars to fog
  # gateway -> gateway_ipv4
  # range -> ipv4_range
  def init_create
    extra_args = {:ipv4_range => resource[:range]}
    extra_args[:gateway_ipv4] = resource[:gateway] if resource[:gateway]
    extra_args
  end

end
