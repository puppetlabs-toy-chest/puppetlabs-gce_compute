Puppet::Type.newtype(:gce_instance) do

  desc <<-EOT

  Manages machine instances using the gce APIs'

  Implemented as a Puppet device.

  EOT

  apply_to_device

  ensurable

  newparam(:name, :namevar => true) do
    desc 'name used to identify the instance'
  end

  newparam(:authorized_ssh_keys) do
    desc 'key value pairs of user:keypair_name'
    validate do |v|
      raise(Puppet::Error, 'Value should be a hash') unless v.is_a? Hash
    end
  end

  newparam(:description) do
    desc 'description of instance'
  end

  # I am not entirely sure what this looks like
  newparam(:disk) do
    desc 'Disk that should be attached to an instance'
  end

  newparam(:external_ip_address) do
    desc 'external ip address to assign. Takes ephemeral, None, or an ip addr'
  end

  newparam(:image) do
   desc 'image used to launch your instance'
  end

  newparam(:machine_type) do
    desc 'Machines resource profile. Determines amount of CPU, RAM, and disk.'
  end

  newparam(:network) do
    desc 'Network that an instance belongs to'
  end

  newparam(:service_account)
  newparam(:service_account_scopes)

  newparam(:tags) do
    desc 'tags that can be used for filtering and to create firewall rules'
  end

  newparam(:metadata) do
    desc 'meta data that can be associated with an instance'
  end

  newparam(:use_compute_key) do
    desc 'If the default google compute key should be added to the instance'
    newvalues(true, false)
  end

  newparam(:wait_until_running) do
    desc 'rather the program should wait until the instance is in a running state'
  end

  newparam(:zone) do
    desc 'zone where the instance will reside'
  end

  newparam(:auth_file) do
    desc 'Authorization file. In general, this is retrieved from device.conf'
  end

  newparam(:project_id) do
    desc 'id of the project. In the general case, this is retrieved from device.conf.'
  end

  # classification specific parameters
  # newparam(:classes)
  # newparam(:puppet_run_mode)
  # newparam(:content)
  # should this only support agent?

  # I may create somekind of referencing language to retrieve the
  # fact that we will use to fire this sucker up!!
  # this may just be metadata...
  # newparam(:classes) do
  # desc 'a hash of Puppet classes that should be applied to an instance'
  # end

  validate do
    raise(Puppet::Error, "Did not specify required param machine_type") unless self[:machine_type]
    raise(Puppet::Error, "Did not specify required param zone") unless self[:zone]
    #raise(Puppet::Error, "Did not specify required param image") unless self[:image]
  end

end
