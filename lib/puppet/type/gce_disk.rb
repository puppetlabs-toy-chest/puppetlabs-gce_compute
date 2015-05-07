require 'puppet/util/name_validator'

Puppet::Type.newtype(:gce_disk) do
  desc 'Google Compute Engine persistent disk.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of disk.'
    validate do |v|
      Puppet::Util::NameValidator.validate(v)
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
