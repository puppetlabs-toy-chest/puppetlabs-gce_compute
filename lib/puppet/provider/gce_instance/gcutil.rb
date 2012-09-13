require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_instance).provide(
  :gcutil,
  :parent => Puppet::Provider::Gce
) do

  commands :gcutil => 'gcutil'

  def self.subcommand
    'instance'
  end

  def subcommand
    self.class.subcommand
  end

  def parameter_list
    [
      'authorized_ssh_keys',
      'description',
      'disk',
      'external_ip_address',
      'internal_ip_address',
      'image',
      'machine',
      'network',
      'service_account',
      'service_account_scopes',
      'tags',
      'use_compute_key',
      'zone'
    ]
  end

  def create
    args = parameter_list.collect do |attr|
      resource[attr] && "--#{attr}=#{resource[attr]}"
    end.compact
    if resource[:classes]
      # TODO - this needs to be better tested
      # it would be awesome if I can pass entire class manifests to
      # instead of a hash (b/c transforing a hash in bash is going to be
      # a nightmare
      # this will not work as well for puppet agent, but I can look into that later
      class_hash = { 'classes' => parse_refs_from_hash(resource[:classes]) }
      args.push("--metadata=puppet_classes:#{class_hash.to_yaml}")
    end
    if resource[:modules]
      args.push("--metadata=puppet_modules:#{resource[:modules]}")
    end
    if resource[:module_repos]
      args.push("--metadata=puppet_repos:#{resource[:module_repos]}")
    end
    if resource[:modules] || resource[:classes]
      script_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'files', 'puppet-community.sh'))
      args.push("--metadata_from_file=startup-script:#{script_file}")
    end
    # always install puppet
    gcutilcmd("add#{subcommand}", resource[:name], args, '--wait_until_running')

    # block for the startup script
    result = nil
    if resource[:block_for_startup_script]
      begin
        status = Timeout::timeout(resource[:startup_script_timeout]) do
          while ( ! result )
            begin
              result = gcutilcmd('ssh', resource[:name], 'cat /tmp/puppet_bootstrap_output')
            rescue Puppet::ExecutionFailure => detail
              sleep 10
              Puppet.debug(detail)
              result = nil
            end
          end
        end
      rescue Timeout::Error
        self.fail('Timed-out waiting for bootstrap script to execute')
      end
      exit_code = result.split("\n").last.to_s

      self.fail("Startup script failed with exit code: #{exit_code}") unless exit_code == '0'
    end
  end

  def parse_refs_from_hash(hash)
    str = hash.to_pson
    new_string = ''
    while(m = /Gce_instance\[(\S+)\]\[(\S+)\]/.match(str))
      new_string << m.pre_match
      unless resource = model.catalog.resource("Gce_instance[#{m[1]}]")
        raise(Puppet::Error, "Expected Resource Gce_instance[#{m[1]}] does not exist")
      end
      unless property_value = resource.provider.send($2.intern)
        raise(Puppet::Error, "Could not find #{$2.intern} from resource.to_s")
      end
      new_string << property_value
      str = m.post_match
    end
    new_string << str
    PSON.parse(new_string)
  end

  def external_ip_address
    # rebuild the cache if we do not find the property that we are looking for
    # this is b/c I did not implement create to rebuild elements on the cache
    # I may reimplemet this to use flush or something...
    instance = all_compute_objects(gce_device)[resource[:name]]
    (instance && instance[:external_ip]) ||
      (
        self.class.clear_device_objects(gce_device)
        all_compute_objects(gce_device)[resource[:name]][:external_ip]
      )
  end

  def external_ip_address=(value)
    raise(Puppet::Error, "External ip address is a read-only property, it cannot be updated")
  end

  def internal_ip_address
    instance = all_compute_objects(gce_device)[resource[:name]]
    (instance && instance[:network_ip]) ||
      (
        self.class.clear_device_objects(gce_device)
        all_compute_objects(gce_device)[resource[:name]][:network_ip]
      )
  end

  def internal_ip_address=(value)
    raise(Puppet::Error, "Internal ip address is a read-only property, it cannot be updated")
  end

end
