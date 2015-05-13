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
     :scopes             => '--scopes',
     :tags               => '--tags'}
  end

  def create
    args = build_gcloud_create_args
    append_can_ip_forward_args(args, resource)
    append_boot_disk_args(args, resource)
    append_metadata_args(args, resource)
    append_startup_script_args(args, resource)
    gcloud(*args)
    block_for_startup_script(resource)
  end

  def append_can_ip_forward_args(args, resource)
    args << '--can-ip-forward' if resource[:can_ip_forward]
  end

  def append_boot_disk_args(args, resource)
    if resource[:boot_disk]
      args << '--disk'
      args << "name=#{resource[:boot_disk]}"
      args << "boot=yes"
    end
  end

  def append_metadata_args(args, resource)
    if has_metadata_args?(resource)
      args << '--metadata'
      if resource[:metadata]
        resource[:metadata].each do |k, v|
          args << "#{k}=#{v}"
        end
      end
      if resource[:puppet_master]
        args << "puppet_master=#{resource[:puppet_master]}"
      end
      if resource[:puppet_service]
        args << "puppet_service=#{resource[:puppet_service]}"
      end
      if resource[:manifest]
        args << "manifest=#{resource[:manifest]}"
      end
      if resource[:modules]
        args << "puppet_modules=#{resource[:modules]}"
      end
      if resource[:module_repos]
        args << "puppet_repos=#{resource[:module_repos]}"
      end
    end
  end

  def append_startup_script_args(args, resource)
    if resource[:startup_script]
      startup_script_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'files', "#{resource[:startup_script]}"))
      args << '--metadata-from-file'
      args << "startup-script=#{startup_script_file}"
    end
  end

  def block_for_startup_script(resource)
    if resource[:block_for_startup_script]
      begin
        # NOTE if startup_script_timeout is nil, the block will run without timing out
        status = Timeout::timeout(resource[:startup_script_timeout]) do
          loop do
            break if gcloud(*build_gcloud_ssh_startup_script_check_args) =~ /Finished running startup script/
            sleep 10
          end
        end
      rescue Timeout::Error
        fail('Timed out waiting for bootstrap script to execute')
      end
    end
  end

  def build_gcloud_ssh_startup_script_check_args
    ['compute', 'ssh', resource[:name]] + gcloud_args + ['--command', 'tail /var/log/startupscript.log -n 1']
  end

  def has_metadata_args?(resource)
    resource[:metadata] or resource[:puppet_master] or resource[:puppet_service] or resource[:manifest] or resource[:modules] or resource[:module_repos]
  end
end
