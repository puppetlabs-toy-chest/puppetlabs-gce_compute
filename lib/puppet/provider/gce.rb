class Puppet::Provider::Gce < Puppet::Provider

  def conn_opts
    [
      "--credentials_file=#{auth_file}",
      "--project_id=#{project_id}"
    ]
  end

  def auth_file
    gce_device.auth_file
  end

  def project_id
    gce_device.project_id
  end

  def gce_device
    Puppet::Util::NetworkDevice.current || self.class.device_init("[#{@property_hash[:auth_file]}]:#{@property_hash[:project_id]}")
  end

  # retrieve all devices of type gce
  def self.gce_devices
    require 'puppet/util/network_device/config'
    devices = Puppet::Util::NetworkDevice::Config.devices
    ret_hash = {}
    devices.values.each do |dev|
      if dev.provider == 'gce'
        ret_hash[dev.name] = device_init(dev.url)
      end
    end
    ret_hash
  end

  def self.device_init(url)
    require File.expand_path(File.join(File.dirname(__FILE__), '..', 'util', 'network_device', 'gce', 'device'))
    Puppet::Util::NetworkDevice::Gce::Device.new(url)
  end

  def self.gcutilcmd(device, *args)
    gcutil(args, ["--credentials_file=#{device.auth_file}", "--project_id=#{device.project_id}"])
  end

  def gcutilcmd(*args)
    gcutil(args, conn_opts)
  end

end
