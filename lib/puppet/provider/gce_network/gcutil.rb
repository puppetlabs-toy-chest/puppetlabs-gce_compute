require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_network).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'network'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['gateway', 'description', 'range', 'reserve']
  end

end
