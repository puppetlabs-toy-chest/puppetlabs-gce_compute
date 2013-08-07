require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_targetpoolinstance).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'targetpoolinstance'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['name', 'instance', 'region' ]
  end

end
