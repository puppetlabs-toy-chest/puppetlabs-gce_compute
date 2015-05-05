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
    {:description         => '--description',
     :network             => '--network',
     :machine_type        => '--machine-type',
     :on_host_maintenance => '--maintenance-policy',
     :tags                => '--tags'}
  end

  def create
    args = ['compute', gcloud_resource_name, 'create', resource[:name]] + gcloud_args
    gcloud_optional_create_args.each do |attribute, flag|
      if resource[attribute]
        args << flag
        args << resource[attribute]
      end
    end
    args << '--can-ip-forward' if resource[:can_ip_forward]
    gcloud(*args)
  end
end
