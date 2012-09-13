#
# Parent class for all of the Google Compute Engine Providers.
#
class Puppet::Provider::Gce < Puppet::Provider

  def conn_opts
    [
      "--credentials_file=#{gce_device.auth_file}",
      "--project_id=#{gce_device.project_id}"
    ]
  end

  def gce_device
    # this is constantly reloading the device when using puppet apply..
    # needs to be refactored to be faster
    Puppet::Util::NetworkDevice.current || load_device
  end

  # load the device, either using the property has or with the specified cert
  def load_device
    if @property_hash[:project_id] and @property_hash[:auth_file]
      self.class.device("[#{@property_hash[:auth_file]}]:#{@property_hash[:project_id]}")
    else
      unless Puppet[:certname]
        raise(Puppet::Error, "Puppet certname must be specified to load devices")
      end
      my_device = self.class.gce_devices[Puppet[:certname]] ||
        raise(Puppet::Error, "No device found for #{Puppet[:certname]}")
    end
  end

  def self.device(url)
    require File.expand_path(File.join(File.dirname(__FILE__), '..', 'util', 'network_device', 'gce', 'device'))
    Puppet::Util::NetworkDevice::Gce::Device.new(url)
  end

  # retrieve all devices of type gce
  def self.gce_devices
    require 'puppet/util/network_device/config'
    devices = Puppet::Util::NetworkDevice::Config.devices
    ret_hash = {}
    devices.values.each do |dev|
      if dev.provider == 'gce'
        ret_hash[dev.name] = device(dev.url)
      end
    end
    ret_hash
  end

  def self.gcutilcmd(device, *args)
    gcutil(["--credentials_file=#{device.auth_file}", "--project_id=#{device.project_id}"], args)
  end

  def gcutilcmd(*args)
    gcutil(conn_opts, args)
  end

  def self.prefetch(r)
    clear_all_objects
  end

  def self.clear_all_objects
    @compute_object_hash = nil
  end

  def self.clear_device_objects(device)
    @compute_object_hash[device_string(device)] = nil
  end

  def all_compute_objects(device)
    self.class.all_compute_objects(device)
  end

  # cache the full list of objects
  def self.all_compute_objects(device)
    @compute_object_hash ||= {}
    @compute_object_hash[device_string(device)] ||=
      map_all_objects(gcutilcmd(device, "list#{subcommand}s"))
  end

  def self.device_string(device)
    "[#{device.auth_file}]:#{device.project_id}"
  end

  # parses out all of the rows from gcutil return
  # return an array of hashes for each row that maps
  # the colume names to the values for each row
  def self.map_all_objects(output)
    header   = nil
    ret_hash = {}
    (output.split(/\+\n|\|\n/) || []).each do |row|

      if row.start_with?('|')
        cells = row.split('|').collect {|x| x.strip }
        cells.shift
        if header
          row_hash = {}
          header.each_index do |i|
            row_hash[header[i].to_sym] = cells[i]
          end
          ret_hash[row_hash[:name]] = row_hash
        else
          header = cells
        end
      elsif row.start_with?('+')
      else
        Puppet.warning("Unexpted line: #{row}")
      end
    end
    ret_hash
  end

  def self.instances
    gce_devices.values.collect do |dev|
      all_compute_objects(dev).values.collect do |row|
        new(:name => row[:name], :auth_file => dev.auth_file, :project_id => dev.project_id)
      end
    end.flatten
  end

  def create
    #
    # Basically, I am assuming that all parameters defined for
    # the type are flags that need to be set during creation.
    # This is potentially brittle. Everything should really be changed
    # to read only providers.
    #
    args = parameter_list.collect do |attr|
      resource[attr] && "--#{attr}=#{resource[attr]}"
    end.compact
    gcutilcmd("add#{subcommand}", resource[:name], args)
  end

  def destroy
    gcutilcmd("delete#{subcommand}", resource[:name], '-f')
  end

  def exists?
    all_compute_objects(gce_device)[resource[:name]]
  end

end
