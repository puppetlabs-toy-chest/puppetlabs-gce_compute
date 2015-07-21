require 'puppet_x/puppetlabs/name_validator'

Puppet::Type.newtype(:gce_firewallrule) do
  desc 'Google Compute Engine firewall rule.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the firewall rule.'
    validate do |v|
      PuppetX::Puppetlabs::NameValidator.validate(v)
    end
  end

  newparam(:description) do
    desc 'An optional, textual description for the firewall rule.'
  end

  newparam(:allow) do
    desc 'A list of protocols and ports whose traffic will be allowed.'
  end

  newparam(:network) do
    desc 'The network to which this rule is attached. If omitted, the rule is attached to the default network.'
  end

  newparam(:source_ranges) do
    desc 'A list of IP address blocks that are allowed to make inbound connections that match the firewall rule to the instances on the network.'
  end

  newparam(:source_tags) do
    desc 'A list of instance tags indicating the set of instances on the network which may make network connections that match the firewall rule.'
  end

  newparam(:target_tags) do
    desc 'A list of instance tags indicating the set of instances on the network which may make accept inbound connections that match the firewall rule.'
  end

  autorequire(:gce_network) do
    self[:network]
  end
end
