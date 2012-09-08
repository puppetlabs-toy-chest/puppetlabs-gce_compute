Puppet::Type.newtype(:gce_instance) do

  desc <<-EOT

  Manages machine instances using the gce APIs'

  Implemented as a Puppet device.

  EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc 'name used to identify the instance'
    validate do |v|
      unless v =~ /[a-z]([-a-z0-9]*[a-z0-9])?/
        raise(Puppet::Error, "Invalid instance name: #{v}")
      end
    end
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
  # can multiple disks be attached?
  newparam(:disk) do
    desc 'Disk that should be attached to an instance'
  end

  # this assumes that disk is just the disk name
  autorequire :gce_disk do
    self[:disk]
  end

  newproperty(:external_ip_address) do
    desc 'external ip address to assign. Takes ephemeral, None, or an ip addr'
  end

  newproperty(:internal_ip_address) do
    desc 'internal ip address to assign.'
  end

  newparam(:image) do
   desc 'image used to launch your instance'
  end

  newparam(:machine) do
    desc 'Machines resource profile. Determines amount of CPU, RAM, and disk.'
  end

  newparam(:network) do
    desc 'Network that an instance belongs to'
  end

  autorequire :gce_network do
    self[:network]
  end

  newparam(:service_account)
  newparam(:service_account_scopes)

  # needs to support arrays
  newparam(:tags) do
    desc 'tags that can be used for filtering and to create firewall rules'
    validate do |v|
      raise(Puppet::Error, 'Tags can only be arrays or strings') unless v.is_a?(Array) || v.is_a?(String)
    end
    munge do |v|
      v.is_a?(Array) ? v.join(',') : v
    end
  end

  newparam(:metadata) do
    desc 'meta data that can be associated with an instance'
    validate do |v|
      raise(Puppet::Error, "metadata expects a Hash") unless v.is_a?(Hash)
    end
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

#  newparam(:auth_file) do
#    desc 'Authorization file. In general, this is retrieved from device.conf'
#  end
#
#  newparam(:project_id) do
#    desc 'id of the project. In the general case, this is retrieved from device.conf.'
#  end

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


end
