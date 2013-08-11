require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_targetpool).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'targetpool'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['description', 'health_checks', 'instances', 'region' ]
  end

  def destroy_parameter_list
    ['region']
  end

end
