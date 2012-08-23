Puppet::Type.newtype(:gce_disk) do

  desc 'creates a persistent disk image'

  apply_to_device

  ensurable

  newparam(:name, :namevar) do

  end

  # NOTE this could be a property eventually b/c
  # it is possible to migrate disks between zones
  #
  newparam(:zone) do
    desc 'zone where this disk lives'

  end

  newparam(:size_gb) do
    desc 'size in GB for disk'
  end

  validate do
    raise(Puppet::Error, 'Must specify a zone for the disk' unless self[:zone]
  end

end
