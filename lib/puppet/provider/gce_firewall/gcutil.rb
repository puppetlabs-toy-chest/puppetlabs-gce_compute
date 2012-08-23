
Puppet::Type.type(:gce_firewall).provide(
  :gce_util,
  :parent => Puppet::Provider::Gce
) do

  commands 'gceutil' => :gceutil

  def exists?
  end

end
