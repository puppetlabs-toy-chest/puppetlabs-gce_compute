require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_network).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
) do

  confine :true => false

  commands :gcutil => 'gcutil'

  def self.subcommand
    'network'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['gateway', 'description', 'range' ]
  end

  def destroy_parameter_list
    []
  end

end
