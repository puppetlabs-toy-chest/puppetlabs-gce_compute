require 'puppet/parameter/boolean'

Puppet::Type.newtype(:gce_firewall) do

  ensurable

  desc 'type for managing firewalls in google compute'

  newparam(:name, :namevar => true) do
    desc 'name of firewall'
    validate do |v|
      unless v =~ /^[a-z][-a-z0-9]{0,61}[a-z0-9]\Z/
        raise(Puppet::Error, "Invalid firewall name: #{v}")
      end
    end
  end

  newparam(:description) do
    desc 'Description of firewall'
  end

  newparam(:allowed) do
    desc 'List of allowed protocols and ports'
    validate do |v|
     # unless v =~ /(\w+)?:?\d+(-\d+)?/
     #   raise(Puppet::Error, "Invalid allowed string: #{v}.")
     # end
    end
  end

  newparam(:allowed_ip_sources) do
    desc 'List of sources allowed to comminucate to allowed destinations'
  end

  newparam(:allowed_tag_sources) do
    desc 'List of tag sources allowed to comminucate to allowed destinations'
  end

  newparam(:network) do
    desc 'Network on which the firewall resides.'
    defaultto 'default'
  end

  newparam(:target_tags) do
    desc 'Set of tagged instances to apply the firewall rules to'
  end

  autorequire(:gce_network) do
    self[:network]
  end

  newparam(:async_destroy, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'wait until firewall is deleted'
    defaultto :false
  end

  autorequire(:gce_auth) do
    requires = []
    catalog.resources.each {|rsrc|
      requires << rsrc.name if rsrc.class.to_s == 'Puppet::Type::Gce_auth'
    }
    requires
  end

end
