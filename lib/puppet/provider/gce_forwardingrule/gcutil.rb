require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_forwardingrule).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
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

end
