require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_instance).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'instances'
  end

  # These arguments are required for both create and destroy
  def gcloud_args
    ['--zone', resource[:zone]]
  end

  def gcloud_optional_create_args
    {:description        => '--description',
     :address            => '--address',
     :image              => '--image',
     :machine_type       => '--machine-type',
     :network            => '--network',
     :maintenance_policy => '--maintenance-policy',
     :tags               => '--tags'}
  end

  def create
    args = build_gcloud_create_args
    args << '--can-ip-forward' if resource[:can_ip_forward]
    if resource[:boot_disk]
      args << '--disk'
      args << "name=#{resource[:boot_disk]}"
      args << "boot=yes"
    end
    if resource[:metadata]
      args << '--metadata'
      resource[:metadata].each do |k, v|
        args << "#{k}=#{v}"
      end
    end
    if resource[:startup_script]
      startup_script_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'files', "#{resource[:startup_script]}"))
      args << '--metadata-from-file'
      args << "startup-script=#{startup_script_file}"
    end
    gcloud(*args)
  end
end
