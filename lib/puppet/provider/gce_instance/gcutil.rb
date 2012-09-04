require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_instance).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'instance'
  end

  def subcommand
    self.class.subcommand
  end

  def create
    raise(Puppet::Error, "Did not specify required param machine_type") unless resource[:machine]
    raise(Puppet::Error, "Did not specify required param zone") unless resource[:zone]
    raise(Puppet::Error, "Did not specify required param image") unless resource[:image]
    super
  end

end
