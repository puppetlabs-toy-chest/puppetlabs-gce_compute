Puppet::Type.newtype(:gce_targetpoolhealthcheck) do
  desc 'targetpoolhealthcheck'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?/
        raise(Puppet::Error, "Invalid targetpoolhealthcheck name: #{v}")
      end
    end
  end

  newparam(:health_check) do
    desc 'Health check resouce to be added from target pool'
  end

  newparam(:region) do
    desc 'The region for this request'
  end

end
