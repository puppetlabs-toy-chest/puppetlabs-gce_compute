require 'puppet_x/puppetlabs/name_validator'

Puppet::Type.newtype(:gce_address) do
  desc 'Google Compute Engine reserved IP address'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the address.'
    validate do |v|
      PuppetX::Puppetlabs::NameValidator.validate(v)
    end
  end

  newparam(:region) do
    desc 'The region of the address to operate on.'
  end

  newparam(:description) do
    desc 'An optional, textual description for the address.'
  end

  validate do
    fail('You must specify a region for the address.') unless self[:region]
  end
end
