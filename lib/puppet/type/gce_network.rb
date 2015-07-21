require 'puppet_x/puppetlabs/name_validator'

Puppet::Type.newtype(:gce_network) do
  desc 'Google Compute Engine network.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the network.'
    validate do |v|
      PuppetX::Puppetlabs::NameValidator.validate(v)
    end
  end

  newparam(:description) do
    desc 'An optional, textual description for the network.'
  end

  newparam(:range) do
    desc 'Specifies the IPv4 address range of this network. The range must be specified in CIDR format.'
  end

end
