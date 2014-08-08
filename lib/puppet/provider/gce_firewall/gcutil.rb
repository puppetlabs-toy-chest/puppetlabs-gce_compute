require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcutil'))

Puppet::Type.type(:gce_firewall).provide(
  :gcutil,
  :parent => Puppet::Provider::Gcutil
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'firewall'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    ['description', 'allowed', 'allowed_ip_sources', 'allowed_tag_sources',
     'network', 'target_tags']
  end

  def destroy_parameter_list
    []
  end

end
