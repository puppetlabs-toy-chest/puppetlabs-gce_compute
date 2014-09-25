require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_firewall).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  @puppet_fog_mappings = {
    :allowed_ip_sources => :source_ranges,
    :allowed_tag_sources => :source_tags
  }

  def self.puppet_fog_mappings(attr)
    @puppet_fog_mappings[attr]
  end

  def puppet_fog_mappings(attr)
    self.class.puppet_fog_mappings(attr)
  end

  def self.subtype
    superclass.connection.firewalls
  end

  def subtype
    self.class.subtype
  end

  def self.parameter_list
    [:description, :allowed, :allowed_ip_sources, :allowed_tag_sources,
     :network, :target_tags, :async_destory]
  end

  # Puppet to fog var name mapping:
  # allowed_ip_sources -> source_ranges
  # allowed_tag_sources -> source_tags
  def init_create
    # Parse allowed so that fog will accept it, assume comma separated list
    # for now as current appendix code found at
    # https://cloud.google.com/developers/articles/google-compute-engine-management-puppet-chef-salt-ansible-appendix
    # shows allowed as string. This should be deprecated though and switched
    # to an array. Part of the following will have to be rewritten to handle
    # arrays instead of comma separated lists, but parsing will be a little
    # cleaner.

    resource[:allowed_ip_sources] = '0.0.0.0/0' unless resource[:allowed_ip_sources] or resource[:allowed_tag_sources]

    addedRules = {} # Just to put all rules with the same protocol together
    rules = resource[:allowed].split(',')
    rules.each {|spec|
      spec.strip!
      proto, portRange = spec.split(':')
      # Ports must be translated to numbers
      port = nil
      if portRange
        low, high = portRange.split('-')
        begin
          port = Socket.getservbyname(low).to_s
          port += '-' + Socket.getservbyname(high).to_s if high
        rescue SocketError => e
          raise(Puppet::Error, e)
        end
      end
      if addedRules.include? proto
        if not portRange  # Check that the new rule is not all ports
          addedRules[proto] = []
        elsif not addedRules[proto].empty? # If a rule is empty all ports should be open
          addedRules[proto] << port
        end
      else
        addedRules[proto] = [port].compact # Get rid of nil portRange for all ports open
      end
    }

    resource[:allowed] = addedRules.map {|k,v|
      rules = {:IPProtocol => k}
      rules[:ports] = v.uniq.sort if not v.empty?
      rules
    }

    # TODO: depracate comma separated lists in puppet and use array
    # syntax instead.
    # Remap puppet variables to fog variables
    extra_args = {}
    extra_args[:source_ranges] = resource[:allowed_ip_sources].split(',').collect {|x|
      x.strip
    } if resource[:allowed_ip_sources]
    extra_args[:source_tags] = resource[:allowed_tag_sources].split(',').collect {|x|
      x.strip
    } if resource[:allowed_tag_sources]
    extra_args
  end 

end
