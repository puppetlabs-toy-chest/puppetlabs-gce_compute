require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

# TODO: add support for ip_addess and ip_protocol
Puppet::Type.type(:gce_forwardingrule).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  def self.subtype
    superclass.connection.forwarding_rules
  end

  def subtype
    self.class.subtype
  end

  def self.parameter_list
    [:ip, :description, :port_range, :protocol, :region, :target, :async_destory, :async_create ]
  end

  def init_create
    if resource[:target] then
      if self.class.get_cache[:gce_targetpool][resource[:target]] then
        resource[:target] = self.class.get_cache[:gce_targetpool][resource[:target]].self_link
      else
        raise(Puppet::Error, 'target pool specified for forwarding rule does not exist')
      end
   else
     raise(Puppet::Error, 'Target pool must be specified for forwarding rules')
   end
  resource
  end
end
