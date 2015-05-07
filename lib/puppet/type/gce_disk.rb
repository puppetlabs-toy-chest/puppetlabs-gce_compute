Puppet::Type.newtype(:gce_disk) do

  desc 'Google Compute Engine persistent disk.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of disk.'
    validate do |v|
      unless v =~ /^[a-z]([-a-z0-9]{0,61}[a-z0-9])$/
        fail("Invalid disk name: #{v}.  Must be a match of regex /^[a-z]([-a-z0-9]{0,61}[a-z0-9])$/.")
      end
    end
  end

  newparam(:zone) do
    desc 'The zone of the disk.'
  end

  newparam(:description) do
    desc 'An optional, textual description for the disk.'
  end

  newparam(:size) do
    desc 'Indicates the size (in GB) of the disk.'
  end

  newparam(:image) do
    desc 'An image to apply to the disk.'
  end

  validate do
    fail('You must specify a zone for the disk.') unless self[:zone]
  end
end
