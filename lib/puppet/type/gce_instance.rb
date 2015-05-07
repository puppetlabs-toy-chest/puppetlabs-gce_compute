require 'puppet/util/name_validator'

Puppet::Type.newtype(:gce_instance) do
  desc 'Google Compute Engine virtual machine instance'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the instance'
    validate do |v|
      Puppet::Util::NameValidator.validate(v)
    end
  end

  newparam(:zone) do
    desc 'The zone of the instance.'
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

  newparam(:startup_script) do
    desc 'Specifies a script that will be executed by the instances once they start running.'
  end

  newparam(:tags) do
    desc 'Specifies a list of tags to apply to the instance for identifying the instances to which network firewall rules will apply.'
  end

  # TODO not implemented in gcloud
  # newparam(:authorized_ssh_keys) do
  #   desc 'key value pairs of user:keypair_name'
  #   validate do |v|
  #     raise(Puppet::Error, 'Value should be a hash') unless v.is_a? Hash
  #   end
  # end

  # TODO not implemented in gcloud
  # newproperty(:external_ip_address) do
  #   desc 'external ip address to assign. Takes ephemeral, None, or an ip addr'
  # end

  # TODO not implemented in gcloud
  # newproperty(:internal_ip_address) do
  #   desc 'internal ip address to assign.'
  # end

  # TODO not implemented in gcloud
  # newparam(:service_account)

  # TODO not implemented in gcloud
  # newparam(:service_account_scopes) do
  #   desc 'Service account scopes indicate the level of access the instance has'
  #   validate do |v|
  #     raise(Puppet::Error, 'Scopes can only be arrays or strings') unless v.is_a?(Array) || v.is_a?(String)
  #   end
  #   munge do |v|
  #     v.is_a?(Array) ? v.join(',') : v
  #   end
  # end

# TODO I am going to use metadata for my own custom purposes.
# The laziest way to avoid conflicts is just to not yet users modify
# it. I will likely have to figure out a better solution for this... later
#  newparam(:metadata) do
#    desc 'meta data that can be associated with an instance'
#    validate do |v|
#      raise(Puppet::Error, "metadata expects a Hash") unless v.is_a?(Hash)
#    end
#  end

  # TODO not implemented in gcloud
  # newparam(:add_compute_key_to_project) do
  #   desc 'Try to add the user\'s Google compute key to the project'
  #   newvalues(true, false)
  # end

  # TODO not implemented in gcloud
  # newparam(:use_compute_key) do
  #   desc 'If the default google compute key should be added to the instance'
  #   newvalues(true, false)
  # end

#  NOTE this should always be set to true
#  newparam(:wait_until_running) do
#    desc 'rather the program should wait until the instance is in a running state'
#  end

  # TODO not implemented in gcloud
  # newparam(:block_for_startup_script) do
  #   desc 'whether the resource should block until after the startup script executes'
  #   newvalues(:true, :false)
  # end

  # TODO not implemented in gcloud
  # newparam(:startup_script_timeout) do
  #   desc 'timeout for bootstrap script. If this time is passed before the bootstrap script has finished, the resource will fail'
  #   defaultto '420'
  #   munge do |value|
  #     Integer(value)
  #   end
  # end

#  newparam(:auth_file) do
#    desc 'Authorization file. In general, this is retrieved from device.conf'
#  end
#
#  newparam(:project_id) do
#    desc 'id of the project. In the general case, this is retrieved from device.conf.'
#  end

  # TODO not implemented in gcloud (Puppet functionality)
  # newparam(:puppet_master) do
  #   desc 'Hostname of the puppet master instance to connect to'
  # end

  # TODO not implemented in gcloud (Puppet functionality)
  # newparam(:puppet_service) do
  #   desc 'Whether to start the puppet service or not'
  #   validate do |v|
  #     raise(Puppet::Error, "puppet_service must be 'absent' or 'present'.") unless v.is_a?(String) and (v == 'absent' or v == 'present')
  #   end
  # end

  # TODO not implemented in gcloud (Puppet functionality)
  # classification specific parameters
  # newparam(:enc_classes) do
  #   desc 'A hash of ENC classes used to assign a Puppet class to this instance.'
  #   validate do |v|
  #     raise(Puppet::Error, "ENC classes expects a Hash.") unless v.is_a?(Hash)
  #   end
  # end

  # TODO not implemented in gcloud (Puppet functionality)
  # manifest specific parameters
  # newparam(:manifest) do
  #   desc 'A local manifest file specific to this instance.'
  #   validate do |v|
  #     raise(Puppet::Error, "Manifest expects to be a String.") unless v.is_a?(String)
  #   end
  # end

  # TODO not implemented in gcloud (Puppet functionality)
  # newparam(:modules) do
  #   desc 'list of modules to be downloaded from the forge. This is only needed for puppet masters or when running in puppet apply mode'
  #   defaultto []
  #   munge do |v|
  #     v.to_a.join(',')
  #   end
  # end

  # TODO not implemented in gcloud (Puppet functionality)
  # newparam(:module_repos) do
  #   desc 'Hash of module repos (localdir => repo) to be downloaded from github. Ex. apache => git@github.com:puppetlabs/puppetlabs-apache.git'
  #   defaultto ''
  #   validate do |v|
  #     raise(Puppet::Error, "module_repos expects a Hash.") unless(v.is_a?(Hash) || v.empty?)
  #   end
  #   munge do |v|
  #     new_value = []
  #     if v.respond_to?('each')
  #       v.each do |v,k|
  #         new_value << "#{k}##{v}"
  #       end
  #     end
  #     new_value.join(',')
  #   end
  # end

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

  autorequire :gce_disk do
    self[:boot_disk]
  end

  autorequire :gce_network do
    self[:network]
  end

  validate do
    fail('You must specify a zone for the instance.') unless self[:zone]
  end
end
