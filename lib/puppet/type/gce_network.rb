Puppet::Type.newtype(:gce_network) do
  desc 'network'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?/
        raise(Puppet::Error, "Invalid network name: #{v}")
      end
    end
  end

  newparam(:gateway) do
    desc 'gateway'
    validate do |value|
      unless value =~ /[0-9]{1,3}(?:\.[0-9]{1,3}){3}/
        raise "Invalid gateway IP address #{value}"
      end
    end
  end

  newparam(:description) do
    desc 'network description'
  end

  newparam(:range) do
    desc 'CIDR for ipv4 network'
    validate do |value|
      unless value =~ /[0-9]{1,3}(?:\.[0-9]{1,3}){3}\/[0-9]{1,2}/
        raise "Invalid network range #{value}"
      end
    end
  end

end
