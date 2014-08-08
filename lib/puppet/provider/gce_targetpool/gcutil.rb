require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcutil'))

Puppet::Type.type(:gce_targetpool).provide(
  :gcutil,
  :parent => Puppet::Provider::Gcutil
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'targetpool'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['description','region','health_checks','instances','session_affinity','backup_pool','failover_ratio' ]
  end

  def destroy_parameter_list
    ['region']
  end

end
