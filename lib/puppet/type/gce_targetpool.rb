Puppet::Type.newtype(:gce_targetpool) do
  desc 'targetpool'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?/
        raise(Puppet::Error, "Invalid targetpool name: #{v}")
      end
    end
  end

  newparam(:description) do
    desc 'targetpool description'
  end

  newparam(:health_checks) do
    desc 'Comma separated list of HttpHealthChecks'
  end

  newparam(:instances) do
    desc 'Comma separated list of "zone/instance" pairs that will be in this pool'
  end

  newparam(:region) do
    desc 'The region for this request'
  end

end
