Puppet::Type.newtype(:network) do
  desc 'network'

  apply_to_device

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless v =~ /[a-z]([-a-z0-9]*[a-z0-9])?/
        raise(Puppet::Error, "Invalid network firewall name: #{v}")
      end
    end
  end
  newparam(:ipv4_gateway) do
    desc 'gateway'
  end
  newparam(:ipv4_range) do
    desc 'CIDR for ipv4 network'
    validate do |value|
      unless value =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(\d|[1-2]\d|3[0-2]))$/
        raise "Invalid network range #{value}"
      end
    end
  end
end
