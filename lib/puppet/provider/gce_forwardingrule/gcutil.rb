require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcutil'))

Puppet::Type.type(:gce_forwardingrule).provide(
  :gcutil,
  :parent => Puppet::Provider::Gcutil
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'forwardingrule'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['ip', 'description', 'port_range', 'protocol', 'region', 'target' ]
  end

  def destroy_parameter_list
    ['region']
  end

end
