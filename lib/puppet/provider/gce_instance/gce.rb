require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

# TODO:  add support for wait_for_startup_script
# TODO:  add support for generic metadata_from_file. Right now it only
# supports it for startup-script
# TODO:  add support for creating a disk and an instance at the same
# time. Users are currently allowed to specify an image for an instance
Puppet::Type.type(:gce_instance).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  def self.subtype
     superclass.connection.servers
  end

  def subtype
    self.class.subtype
  end

  def self.parameter_list
    [:authorized_ssh_keys, :description, :disk, :external_ip_address,
      :internal_ip_address, :image, :machine_type, :network,
      :on_host_maintenance, :service_account, :service_account_scopes, :tags,
      :add_compute_key_to_project, :use_compute_key, :can_ip_forward, :zone,
      :metadata, :async_destory, :async_create]
  end

  # Used for when keys are added to the project
  def self.project_ssh_keys=(keys)
    @project_ssh_keys = keys
  end

  def self.project_ssh_keys
    self.get_project_ssh_keys unless @project_ssh_keys
    @project_ssh_keys
  end

  def self.get_project_ssh_keys
    project = superclass.connection.projects.get(superclass.connection.project)
    # Go through hash of metadata looking for sshKeys
    project.common_instance_metadata['items'].each {|hsh|
      if hsh.has_value?('sshKeys')
        @project_ssh_keys = hsh['value']
        break
      end
    } if project.common_instance_metadata['items']

    # We want this to be not nil so we don't call this method again later if
    # there are no keys
    @project_ssh_keys ||= '' 
  end

  def self.add_key_to_project(pub_key)
    if not self.project_ssh_keys =~ /#{Regexp.escape(pub_key)}/
      user = ENV['SUDO_USER'] ? ENV['SUDO_USER'] : ENV['USER']
      self.project_ssh_keys = self.project_ssh_keys + "\n#{user}:#{pub_key}"

      proj= superclass.connection.projects.get(superclass.connection.project)
      meta = proj.common_instance_metadata
      metaHash = {}
      meta['items'].each {|hsh|
        metaHash[hsh['key']] = hsh['value']
      } if meta['items']
      metaHash['sshKeys'] = self.project_ssh_keys
      proj.set_metadata(metaHash)
    end
  end

  # Returns the local google_compute_engine ssh key. If one does not exist it
  # creates one.
  def self.get_local_ssh_key
    # This whole section is really screwy, but the thing is this process could
    # be running as root or as a user. If it was run with sudo it would be
    # preferable to generate the key for the user who called sudo, not root.
    user = ENV['SUDO_USER'] ? ENV['SUDO_USER'] : ENV['USER']
    uid = ENV['SUDO_UID'] ? ENV['SUDO_UID'].to_i : Process.uid.to_i
    ssh_dir= File.expand_path(File.join("~#{user}", '.ssh'))
    private_key = 'google_compute_engine'
    public_key = "#{private_key}.pub"
    Dir.mkdir(ssh_dir, 0700) unless Dir.exists?(ssh_dir)
    if not File.exists?(File.join(ssh_dir, private_key)) and not \
      File.exists?(File.join(ssh_dir, public_key))
      Puppet::Util::Warnings.warnonce("Generating key file at #{File.join(ssh_dir, private_key)}")
      `ssh-keygen -t rsa -q -f #{File.join(ssh_dir, private_key)} -C #{user}@#{Facter.value('hostname')}`
      # Correct file permissions so that everything works correctly when sshing
      File.chown(uid, uid, File.join(ssh_dir, private_key))
      File.chown(uid, uid, File.join(ssh_dir, public_key))
    end
    # TODO:  Check if key should be validated
    pub_key = File.open(File.join(ssh_dir, public_key), 'r') {|f|
      f.read.strip
    }
    raise(Puppet::Error, 'Invalid ssh key') if pub_key =~ /\n/
    pub_key
  end

  # TODO:  deprecate disk and move to disks to support newer API and
  # the fact that multiple disks can be attached to a VM.
  def init_create
    # temp_disks merges disk and disks into a single array for fog
    temp_disks = ([resource[:disk]] + resource[:disks]).compact
    resource[:disks] = []
    temp_disks.each {|dsk|
      name, boot = dsk.split(',').collect {|x|
        x.strip
      }
      disk = self.class.get_cache[:gce_disk][name]
      raise(Puppet::Error, "Unable to find disk with name #{name}") unless disk
      if boot == 'boot'
        resource[:disks].unshift(disk)
      else
        resource[:disks] << disk
      end
    }

    resource[:metadata] ||= {}
    resource[:metadata_from_file] ||= {}
    if resource[:puppet_master]
      resource[:metadata][:puppet_master] = resource[:puppet_master]
    else
      resource[:metadata][:puppet_master] = :puppet
    end
    if resource[:puppet_service]
      resource[:metadata][:puppet_service] = resource[:puppet_service]
    end

    #TODO: figure out what enc_classes does
    if resource[:enc_classes]
      class_hash = { 'classes' => parse_refs_from_hash(resource[:enc_classes]) }
      resource[:metadata][:puppet_classes] = class_hash.to_yaml
    end
    if resource[:manifest]
      resource[:metadata][:puppet_manifest] = resource[:manifest]
    end
    if not resource[:modules].empty?
      resource[:metadata][:puppet_modules] = resource[:modules]
    end
    if not resource[:module_repos].empty?
      resource[:metadata][:puppet_repos] = resource[:module_repos]
    end
    if resource[:puppet_master] ||
      resource[:puppet_service] ||
      resource[:manifest] ||
      resource[:modules] ||
      resource[:enc_classes] ||
      resource[:module_repos] ||
      resource[:startupscript]
      # if we specified any classification info, we should call the bootstrap
      # script
      if resource[:startupscript]
        script_file = File.expand_path(File.join(File.dirname(__FILE__), '..',
                                                 '..', '..', '..', 'files',
                                                 "#{resource[:startupscript]}"))
      else
        script_file = File.expand_path(File.join(File.dirname(__FILE__), '..',
                                                 '..', '..', '..', 'files',
                                                 'puppet-community.sh'))
      end
      metadata_file_contents ={'startup-script'=> File.open(script_file,"r").read}
      resource[:metadata].merge!(metadata_file_contents)
    end

    # TODO: raise an error if add compute key and authorized keys both set?
    # Add the puppet master's ssh key to the common project metadata if true.
    if resource[:add_compute_key_to_project]
      self.class.add_key_to_project(self.class.get_local_ssh_key)
    end

    # Either add specified ssh keys or the authorized ssh keys from the project
    if resource[:authorized_ssh_keys]
      keys = resource[:authorized_ssh_keys].shift.join(':')
      resource[:authorized_ssh_keys].each {|key, value|
        keys += "\n#{key}:#{value}"
      }
      resource[:metadata][:sshKeys] = keys
    elsif not self.class.project_ssh_keys.empty?
      resource[:metadata][:sshKeys] = self.class.project_ssh_keys
    end

    nil
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

  # TODO: go through and figure out which of these we need
=begin
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
=end

  def external_ip_address=(value)
    raise(Puppet::Error, "External ip address is a read-only property, it cannot be updated")
  end

=begin
  def internal_ip_address
    instance = all_compute_objects(gce_device)[resource[:name]]
    (instance && instance[:network_ip]) ||
      (
        self.class.clear_device_objects(gce_device)
        all_compute_objects(gce_device)[resource[:name]][:network_ip]
      )
  end
=end

  def internal_ip_address=(value)
    raise(Puppet::Error, "Internal ip address is a read-only property, it cannot be updated")
  end

end
