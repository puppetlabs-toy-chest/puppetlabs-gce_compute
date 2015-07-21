require 'puppet_x/puppetlabs/name_validator'

Puppet::Type.newtype(:gce_forwardingrule) do
  desc 'Google Compute Engine forwarding rule to send traffic to load balancers'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the forwarding rule.'
    validate do |v|
      PuppetX::Puppetlabs::NameValidator.validate(v)
    end
  end

  newparam(:region) do
    desc 'The region of the forwarding rule to operate on.'
  end

  newparam(:description) do
    desc 'An optional, textual description for the forwarding rule.'
  end

  newparam(:address) do
    desc 'The external IP address that the forwarding rule will serve.'
  end

  newparam(:ip_protocol) do
    desc 'The IP protocol that the rule will serve. If left empty, TCP is used.'
    validate do |v|
      unless ['AH', 'ESP', 'SCTP', 'TCP', 'UDP'].include? v
        fail("Invalid protocol: #{v}. Supported protocols are: AH, ESP, SCTP, TCP, and UDP.")
      end
    end
  end

  newparam(:port_range) do
    desc 'If specified, only packets addressed to ports in the specified range will be forwarded.'
  end

  newparam(:target_pool) do
    desc 'The target pool that will receive the traffic.'
  end

  validate do
    fail('You must specify a region for the forwarding rule.') unless self[:region]
  end

  autorequire(:gce_address) do
    self[:address]
  end

  autorequire(:gce_targetpool) do
    self[:target_pool]
  end
end
