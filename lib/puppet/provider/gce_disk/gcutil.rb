Puppet::Type.type(:gce_disk).provide(
  :gce_util,
  :parent => Puppet::Provider::Gce) do

  commands 'gceutil' => :gceutil

  def exists?
  end

end
