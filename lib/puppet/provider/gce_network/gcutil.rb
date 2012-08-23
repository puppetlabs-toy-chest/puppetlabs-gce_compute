require File.expand_path(File.join(File.dirname("__FILE__", '..', 'gce')))

Puppet::Type.type(:gce_network).provide(
  :gce_util,
  :parent => Puppet::Provider::Gce
) do

  commands 'gceutil' => :gceutil

  def exists?
  end

end
