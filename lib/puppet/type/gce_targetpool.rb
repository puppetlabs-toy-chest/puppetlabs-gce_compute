require 'puppet/util/name_validator'

Puppet::Type.newtype(:gce_targetpool) do
  desc 'Google Compute Engine target pool to handle network load balancing'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the target pool.'
    validate do |v|
      Puppet::Util::NameValidator.validate(v)
    end
  end

  newparam(:region) do
    desc 'The region of the target pool.'
  end

  newparam(:description) do
    desc 'An optional, textual description for the target pool.'
  end

  newparam(:backup_pool) do
    desc 'If the ratio of the healthy instances in the primary pool is at or below the specified failover ratio value, then traffic arriving at the load-balanced IP address will be directed to the backup pool.'
  end

  newparam(:failover_ratio) do
    desc 'If the ratio of the healthy instances in the primary pool is at or below this number, traffic arriving at the load-balanced IP address will be directed to the backup pool.'
  end

  newparam(:health_check) do
    desc 'Specifies an HTTP health check resource to use to determine the health of instances in this pool.'
  end

  newparam(:session_affinity) do
    desc 'Specifies the session affinity option for the connection.'
  end

  autorequire(:gce_targetpool) do
    self[:backup_pool]
  end

  autorequire(:gce_httphealthcheck) do
    self[:health_check]
  end

  validate do
    if (self[:backup_pool] and self[:failover_ratio].nil?) or (self[:backup_pool].nil? and self[:failover_ratio])
      fail('Either both or neither of backup_pool and failover_ratio must be provided.')
    end
  end
end
