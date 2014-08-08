require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcutil'))

Puppet::Type.type(:gce_targetpoolhealthcheck).provide(
  :gcutil,
  :parent => Puppet::Provider::Gcutil
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'targetpoolhealthcheck'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['name', 'health_check', 'region' ]
  end

  def destroy_parameter_list
    ['region']
  end

end
