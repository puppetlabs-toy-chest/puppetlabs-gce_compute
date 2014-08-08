require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcutil'))

Puppet::Type.type(:gce_network).provide(
  :gcutil,
  :parent => Puppet::Provider::Gcutil
) do

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
