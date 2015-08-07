require 'puppet_x/puppetlabs/name_validator'

Puppet::Type.newtype(:gce_instance) do
  desc 'Google Compute Engine virtual machine instance'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the instance'
    validate do |v|
      PuppetX::Puppetlabs::NameValidator.validate(v)
    end
  end

  newparam(:zone) do
    desc 'The zone of the instance.'
  end

  newparam(:address) do
    desc 'Assigns the given external address to the instance that is created.'
  end

  newparam(:can_ip_forward) do
    desc 'If provided, allows the instances to send and receive packets with non-matching destination or source IP addresses.'
  end

  newparam(:description) do
    desc 'An optional, textual description for the instance.'
  end

  newparam(:boot_disk) do
    desc 'Specifies a persistent disk as the boot disk for this instance.'
  end

  newparam(:image) do
   desc 'Specifies the boot image for the instance.'
  end

  newparam(:machine_type) do
    desc 'Specifies the machine type used for the instance.'
  end

  newparam(:metadata) do
    desc 'Metadata to be made available to the guest operating system running on the instances.'
  end

  newparam(:network) do
    desc 'Specifies the network that the instance will be part of.'
  end

  newparam(:maintenance_policy) do
    desc 'Specifies the behavior of the instances when their host machines undergo maintenance.'
  end

  newparam(:scopes) do
    desc 'Specifies service accounts and scopes for the instances.'
  end

  newparam(:startup_script) do
    desc 'Specifies a script that will be executed by the instances once they start running.'
  end

  newparam(:block_for_startup_script) do
    desc 'Whether the instance creation should block until the startup script has finished executing.'
  end

  newparam(:startup_script_timeout) do
    desc 'When provided with :block_for_startup_script, the blocking will timeout after this time (in seconds) has elapsed, and the resource creation will fail, (although the instance will likely have been created).'
    munge { |t| Float(t) }
  end

  newparam(:tags) do
    desc 'Specifies a list of tags to apply to the instance for identifying the instances to which network firewall rules will apply.'
  end

  newparam(:puppet_master) do
    desc 'Hostname of the puppet master instance to connect to.'
  end

  newparam(:puppet_service) do
    desc 'Whether to start the puppet service or not'
    newvalues(:present, :absent)
  end

  newparam(:puppet_manifest) do
    desc 'An inline manifest specific to this instance.'
  end

  newparam(:puppet_modules) do
    desc 'List of modules to be downloaded from the forge. This is only needed for puppet masters or when running in puppet apply mode.'
    munge { |v| v.join(' ') }
  end

  newparam(:puppet_module_repos) do
    desc 'Hash of module repos (localdir => repo) to be downloaded from github. Ex. apache => git@github.com:puppetlabs/puppetlabs-apache.git'
    munge do |v|
      new_value = []
      if v.respond_to?('each')
        v.each do |v,k|
          new_value << "#{k}##{v}"
        end
      end
      new_value.join(' ')
    end
  end

  autorequire :gce_disk do
    self[:boot_disk]
  end

  autorequire :gce_network do
    self[:network]
  end

  validate do
    fail('You must specify a zone for the instance.') unless self[:zone]
    if self[:block_for_startup_script]
      fail('You must specify a startup script if :block_for_startup_script is set to true.') unless self[:startup_script]
    end
    if self[:startup_script_timeout]
      fail(':block_for_startup_script must be set to true if you specify :startup_script_timeout.') unless self[:block_for_startup_script]
    end
  end
end
