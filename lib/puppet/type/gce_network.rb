require 'puppet/parameter/boolean'

Puppet::Type.newtype(:gce_network) do
  desc 'network'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      # Lame check, but the last character can't be a '-' and I don't know how
      # to ensure that with regex when the length is variable
      unless value =~ /^[a-z][-a-z0-9]{0,61}[a-z0-9]\Z/
        raise(Puppet::Error, "Invalid network name: #{value}")
      end
    end
  end

  newparam(:gateway) do
    desc 'gateway'
    validate do |value|
      unless value =~ /^[0-9]{1,3}(?:\.[0-9]{1,3}){3}\Z/
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
      unless value =~ /^[0-9]{1,3}(?:\.[0-9]{1,3}){3}\/[0-9]{1,2}\Z/
        raise "Invalid network range #{value}"
      end
    end
  end
  
  newparam(:async_destroy, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'wait until network is deleted'
    defaultto :false
  end

  autorequire(:gce_auth) do
    requires = []
    catalog.resources.each {|rsrc|
      requires << rsrc.name if rsrc.class.to_s == 'Puppet::Type::Gce_auth'
    }
    requires
  end

end
