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
    desc 'A user-defined description of this target pool.'
  end

  newparam(:region) do
    desc 'The region for this request'
  end

  newparam(:health_checks) do
    desc 'Comma separated list of HttpHealthChecks'
  end

  # TODO this can't be done on creation; it must be executed separately
  newparam(:instances) do
    desc 'Comma separated list of "zone/instance" pairs that will be in this pool'
  end

  newparam(:session_affinity) do
    desc 'Describes the method used to select a backend virtual machine instance.'
  end

  newparam(:backup_pool) do
    desc 'backup targetpool'
  end

  newparam(:failover_ratio) do
    desc 'failover ratio between 0.0 and 1.0'
  end

  autorequire(:gce_targetpool) do
    self[:backup_pool]
  end

  autorequire(:gce_httphealthcheck) do
    self[:health_checks]
  end
end
