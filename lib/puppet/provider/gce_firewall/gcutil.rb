require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_firewall).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'firewall'
  end

  def subcommand
    self.class.subcommand
  end

end
