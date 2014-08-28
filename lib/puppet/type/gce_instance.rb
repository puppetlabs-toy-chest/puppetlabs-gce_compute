require 'puppet/parameter/boolean'

Puppet::Type.newtype(:gce_instance) do

  desc <<-EOT

  Manages machine instances using the gce APIs'

  Implemented as a Puppet device.

  EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc 'name used to identify the instance'
    validate do |v|
      unless v =~ /^[a-z][-a-z0-9]{0,61}[a-z0-9]\Z/
        raise(Puppet::Error, "Invalid instance name: #{v}")
      end
    end
  end

  newparam(:authorized_ssh_keys) do
    desc 'key value pairs of user:keypair_name. Disables project wide key ' \
      'management if set.'
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
    # So that it doesn't always give a deprecation warning, even if no disk was
    # specified
    validate do |v|
      Puppet::Util::Warnings.warnonce('disk is deprecated. Please use disks instead') if v
    end
  end

  # Added for fog compatability 
  newparam(:disks) do
    desc 'Array of disks that should be attached to an instance'
    defaultto [] 

    # For some reason a single item array in puppet manifests is returned as a
    # string. This ensures that we always have an arry.
    munge do |v|
      v = [v].flatten
    end
  end

  # this assumes that disk is just the disk name
  autorequire :gce_disk do
    requires = []
    requires << self[:disk].split(',')[0] if self[:disk]
    self[:disks].each {|d|
      requires << d.split(',')[0]
    }
    requires
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

  newparam(:machine_type) do
    desc 'Machines resource profile. Determines amount of CPU, RAM, and disk.'
  end

  newparam(:network) do
    desc 'Network that an instance belongs to'
  end

  autorequire :gce_network do
    self[:network]
  end

  # Live Migrate ("migrate") or kill the instance ("terminate") during maintenance
  newparam :on_host_maintenance do
    desc 'How instance should behave when the host machine undergoes maintenance'
  end

  newparam(:service_account)

  newparam(:service_account_scopes) do
    desc 'Service account scopes indicate the level of access the instance has'
    validate do |v|
      raise(Puppet::Error, 'Scopes can only be arrays or strings') unless v.is_a?(Array) || v.is_a?(String)
    end
    munge do |v|
      v.is_a?(Array) ? v.join(',') : v
    end
  end

  newparam(:can_ip_forward)

  # needs to support arrays
  newparam(:tags) do
    desc 'tags that can be used for filtering and to create firewall rules'
    validate do |v|
      raise(Puppet::Error, 'Tags can only be arrays or strings') unless v.is_a?(Array) || v.is_a?(String)
    end
    munge do |v|
      v = v.split(',') if v.is_a?(String)
      v.collect! {|x|
        x.strip
      }
    end
  end
# TODO I am going to use metadata for my own custom purposes.
# The laziest way to avoid conflicts is just to not yet users modify
# it. I will likely have to figure out a better solution for this... later
#  newparam(:metadata) do
#    desc 'meta data that can be associated with an instance'
#    validate do |v|
#      raise(Puppet::Error, "metadata expects a Hash") unless v.is_a?(Hash)
#    end
#  end

  newparam(:add_compute_key_to_project, :boolean => true,
           :parent => Puppet::Parameter::Boolean) do
    desc 'Try to add the user\'s Google compute key to the project'
    defaultto :true
  end

  # TODO: deprecate this and use authorized_ssh_key instead.
  # authorized_ssh_key requires the key value pair, but it is more general than
  # this
  newparam(:use_compute_key, :boolean => true,
           :parent => Puppet::Parameter::Boolean) do
    desc 'If the default google compute key should be added to the instance'
  end

#  NOTE this should always be set to true
#  newparam(:wait_until_running) do
#    desc 'rather the program should wait until the instance is in a running state'
#  end
  newparam(:block_for_startup_script, :boolean => true,
           :parent => Puppet::Parameter::Boolean) do
    desc 'whether the resource should block until after the startup script executes'
  end

  newparam(:startup_script_timeout) do
    desc 'timeout for bootstrap script. If this time is passed before the bootstrap script has finished, the resource will fail'
    defaultto '420'
    munge do |value|
      Integer(value)
    end
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

  newparam(:puppet_master) do
    desc 'Hostname of the puppet master instance to connect to'
  end

  newparam(:puppet_service) do
    desc 'Whether to start the puppet service or not'
    newvalues(:absent, :present)
  end

  # classification specific parameters
  newparam(:enc_classes) do
    desc 'A hash of ENC classes used to assign a Puppet class to this instance.'
    validate do |v|
      raise(Puppet::Error, "ENC classes expects a Hash.") unless v.is_a?(Hash)
    end
  end

  # manifest specific parameters
  newparam(:manifest) do
    desc 'A local manifest file specific to this instance.'
    validate do |v|
      raise(Puppet::Error, "Manifest expects to be a String.") unless v.is_a?(String)
    end
  end

  newparam(:modules) do
    desc 'list of modules to be downloaded from the forge. This is only needed for puppet masters or when running in puppet apply mode'
    defaultto []
    munge do |v|
      v.to_a.join(',')
    end
  end

  newparam(:module_repos) do
    desc 'Hash of module repos (localdir => repo) to be downloaded from github. Ex. apache => git@github.com:puppetlabs/puppetlabs-apache.git'
    defaultto ''
    validate do |v|
      raise(Puppet::Error, "module_repos expects a Hash.") unless(v.is_a?(Hash) || v.empty?)
    end
    munge do |v|
      new_value = []
      if v.respond_to?('each')
        v.each do |v,k|
          new_value << "#{k}##{v}"
        end
      end
      new_value.join(',')
    end
  end

# Adds generic metadata, keys k/v hash into metadata k/v
#
  newparam(:metadata) do
    desc 'Creates vm metadata out of k => v hashes'
    validate do |v|
      raise(Puppet::Error, "metadata expects a Hash.") unless(v.is_a?(Hash) || v.empty?)
    end
  end

# Adds generic metadata from files, keys k/v hash into metadata k/v
#
  newparam(:metadata_from_file) do
    desc 'Creates vm metadata out of k => v hashes where v is a filepath'
    validate do |v|
      raise(Puppet::Error, "metadata expects a Hash.") unless(v.is_a?(Hash) || v.empty?)
    end
  end

  newparam(:startupscript) do
    desc 'Sets startupscript name to load from files/ directory'
  end

  newparam(:async_create, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'wait until instance is ready when creating'
    defaultto :false
  end

  newparam(:async_destroy, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'wait until instance is deleted'
    defaultto :false
  end

# TODO add support for setting top scope parameters
#  newparam(:parameters) do
#    desc 'a hash of '
#  end

# TODO be able to set puppet run mode so users can select either puppet apply
# or puppet agent
#  newparam(:puppet_run_mode) do
#    defaultto 'apply'
#  end

  # I may create somekind of referencing language to retrieve the
  # fact that we will use to fire this sucker up!!
  # this may just be metadata...
  # newparam(:classes) do
  # desc 'a hash of Puppet classes that should be applied to an instance'
  # end

  validate do
    if self[:ensure] == :present
      raise(Puppet::Error, "Did not specify required param machine_type") unless self[:machine_type]
      raise(Puppet::Error, "Did not specify required param zone") unless self[:zone]
      raise(Puppet::Error, "Did not specify required param image or disk") unless self[:image] or self[:disk] or not self[:disks].empty?
    end
  end

  autorequire(:gce_auth) do
    requires = []
    catalog.resources.each {|rsrc|
      requires << rsrc.name if rsrc.class.to_s == 'Puppet::Type::Gce_auth'
    }
    requires
  end

end
