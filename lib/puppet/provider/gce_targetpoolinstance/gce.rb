require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_targetpoolinstance).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  def self.subtype
    superclass.connection.target_pool.add_instance
  end

  def subtype
    self.class.subtype
  end

  def self.parameter_list
    [:instance, :region ]
  end

  def destroy_parameter_list
    ['instance', 'region' ]
  end

end
