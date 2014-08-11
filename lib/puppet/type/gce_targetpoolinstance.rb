Puppet::Type.newtype(:gce_targetpoolinstance) do
  desc 'targetpoolinstance'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /^[a-z][-a-z0-9]{0,61}[a-z0-9]\Z/
        raise(Puppet::Error, "Invalid targetpoolinstance name: #{value}")
      end
    end
  end

  newparam(:instance) do
    desc 'Instance resouce (zone/instance format) to be added from target pool'
  end

  newparam(:region) do
    desc 'The region for this request'
  end

  autorequire(:gce_auth) do
    requires = []
    catalog.resources.each {|rsrc|
      requires << rsrc.name if rsrc.class.to_s == 'Puppet::Type::Gce_auth'
    }
    requires
  end

end
