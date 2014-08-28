require 'puppet/parameter/boolean'
 
 

Puppet::Type.newtype(:gce_disk) do

  desc 'creates a persistent disk image'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'name of disk to create'
    validate do |v|
      unless v =~ /^[a-z][-a-z0-9]{0,61}[a-z0-9]\Z/
        raise(Puppet::Error, "Invalid disk name: #{v}")
      end
    end
  end

  newparam(:zone) do
    desc 'zone where this disk lives'
  end

  newparam(:size_gb) do
    desc 'size in GB for disk'
  end

  newparam(:description) do
    desc 'description of disk'
  end

  newparam(:source_image) do
    desc 'boot image to use when creating disk'
  end

  # TODO: deprecate this in later versions. Instead use async_create
  # and async_destroy
  newparam(:wait_until_complete) do
    desc 'wait until disk is complete'
  end

  newparam(:async_create, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'wait until disk is ready when creating'
    defaultto :false
  end

  newparam(:async_destroy, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'wait until disk is deleted'
    defaultto :false
  end

  validate do
    if self[:ensure] == :present
        raise(Puppet::Error, 'Must specify a zone for the disk') unless self[:zone]
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
