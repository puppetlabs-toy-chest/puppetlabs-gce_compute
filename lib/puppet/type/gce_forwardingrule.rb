Puppet::Type.newtype(:gce_forwardingrule) do
  desc 'forwardingrule'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?/
        raise(Puppet::Error, "Invalid forwardingrule name: #{v}")
      end
    end
  end

  newparam(:ip) do
    desc 'the project-reserved IP address for the forwarding rule'
    validate do |value|
      unless value =~ /[0-9]{1,3}(?:\.[0-9]{1,3}){3}/
        raise "Invalid IP address #{value}"
      end
    end
  end

  newparam(:description) do
    desc 'forwardingrule description'
  end

  newparam(:protocol) do
    desc 'The IP protocol for the forwarding rule, TCP or UDP'
    validate do |value|
      unless ['TCP', 'UDP'].include? value
        raise "Protocol value can only be 'TCP' or 'UDP': #{value}"
      end
    end
  end

  newparam(:port_range) do
    desc 'If protocol is TCP, the port range for the forwarding rule'
  end

  newparam(:region) do
    desc 'The specified region for the forwarding rule'
  end

  newparam(:target) do
    desc 'The name of the target pool for the forwarding rule'
  end

  autorequire(:gce_targetpool) do
    self[:target]
  end
end
