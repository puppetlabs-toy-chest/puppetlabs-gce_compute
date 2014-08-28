require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcutil'))

Puppet::Type.type(:gce_disk).provide(
  :gcutil,
  :parent => Puppet::Provider::Gcutil
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'disk'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    [ 'zone', 'size_gb', 'description', 'wait_until_complete', 'source_image' ]
  end

  def destroy_parameter_list
    [ 'zone' ]
  end

end
