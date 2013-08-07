Puppet::Type.newtype(:gce_targetpoolinstance) do
  desc 'targetpoolinstance'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?/
        raise(Puppet::Error, "Invalid targetpoolinstance name: #{v}")
      end
    end
  end

  newparam(:instance) do
    desc 'Instance resouce (zone/instance format) to be added from target pool'
  end

  newparam(:region) do
    desc 'The region for this request'
  end

end
