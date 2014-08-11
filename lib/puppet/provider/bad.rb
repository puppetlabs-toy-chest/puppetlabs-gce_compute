 
 
#
# Parent class for all of the Google Compute Engine Providers.
#
class Puppet::Provider::Fog < Puppet::Provider

  def create_connection
    @connection = Fog::Compute.new({
      :provider => 'google',
      :google_project => 'upbeat-airway-600',
      :google_client_email => '793012070718-d7hg25tf75lkl8kae21q1fp70qmi6tcb@developer.gserviceaccount.com',
      :google_key_location => '/home/ashmrtnz/690c8ebf2431e5020e6c1c3aed048c81a470645a-privatekey.p12',
    })
  end

  def fog_device
    # this is constantly reloading the device when using puppet apply..
    # needs to be refactored to be faster
    require 'puppet/util/network_device'
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
      my_device = self.class.fog_devices[Puppet[:certname]] ||
        raise(Puppet::Error, "No device found for #{Puppet[:certname]}")
    end
  end

  def self.device(url)
    require File.expand_path(File.join(File.dirname(__FILE__), '..', 'util', 'network_device', 'fog', 'device'))
    Puppet::Util::NetworkDevice::Fog::Device.new(url)
  end

  #replace me with list devices?
  # retrieve all devices of type gce
  def self.fog_devices
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

  def self.fogcmd(device, *args)
    puts "gcutilcmd with 2 args called"
    conn_opts = []
    conn_opts << "--nocheck_for_new_version"
    conn_opts << "--service_version=v1"
    conn_opts << "--project=#{device.project_id}" \
      unless device.project_id.empty?
    conn_opts << "--credentials_file=#{device.auth_file}" \
      unless device.auth_file.empty? or (device.auth_file == "/dev/null")
    gcutil(conn_opts, args)
  end

  def gcutilcmd(*args)
    puts "gcutilcmd with 1 arg called"
    #p args
    self.class.fogcmd(fog_device, args)
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
    # TODO for 'list<resource>' gcutils requests, would likely
    #      be better to pass --format=json and parse the json
    header   = nil
    ret_hash = {}
    (output.split(/\+\n|\|\n/) || []).each do |row|

      if row.start_with?('|')
        cells = row.split('|').collect {|x| x.strip }
        cells.shift
        if ["code", "NO_RESULTS_ON_PAGE"].include? cells[0] then
          next
        end
        if header
          row_hash = {}
          header.each_index do |i|
            row_hash[header[i].to_sym] = cells[i]
          end
          ret_hash[row_hash[:name]] = row_hash
        else
          header = cells
        end
      end
    end
    ret_hash
  end

  def self.instances
    fog_devices.values.collect do |dev|
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
    # TODO: change this so they aren't strings list of symbols
    binding.pry
    args = parameter_list.compact # Array of key / value pairs of attributes
    create_connection unless @connection
    # TODO: figure out how to use command line fog
    @connection.subcommand.create(args)
  end

  def destroy
    args = destroy_parameter_list.collect do |attr|
      resource[attr] && "--#{attr}=#{resource[attr]}"
    end.compact
    if ["targetpoolhealthcheck", "targetpoolinstance"].include? subcommand then
      maincmd = "remove"
    else
      maincmd = "delete"
    end
    gcutilcmd("#{maincmd}#{subcommand}", resource[:name], '-f', args)
  end

  def exists?
    all_compute_objects(fog_device)[resource[:name]]
  end

end
