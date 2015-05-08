require 'puppet/util/name_validator'

Puppet::Type.newtype(:gce_forwardingrule) do
  desc 'Google Compute Engine forwarding rule to send traffic to load balancers'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the forwarding rule.'
    validate do |v|
      Puppet::Util::NameValidator.validate(v)
    end
  end

  newparam(:region) do
    desc 'The region of the forwarding rule to operate on.'
  end

  newparam(:description) do
    desc 'An optional, textual description for the forwarding rule.'
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

  # TODO not implemented in gcloud
  # newparam(:ip) do
  #   desc 'the project-reserved IP address for the forwarding rule'
  #   validate do |value|
  #     unless value =~ /[0-9]{1,3}(?:\.[0-9]{1,3}){3}/
  #       raise "Invalid IP address #{value}"
  #     end
  #   end
  # end

  validate do
    fail('You must specify a region for the forwarding rule.') unless self[:region]
  end

  autorequire(:gce_targetpool) do
    self[:target_pool]
  end
end
