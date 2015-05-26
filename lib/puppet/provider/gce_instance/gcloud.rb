require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_instance).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  confine :gcloud_compatible_version => true
  commands :gcloud => "gcloud"

  BLOCK_FOR_STARTUP_SCRIPT_INTERVAL = 10

  def gcloud_resource_name
    'instances'
  end

  # These arguments are required for both create and destroy
  def gcloud_args
    {:zone => '--zone'}
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

  def puppet_metadata
    {'puppet_master'       => :puppet_master,
     'puppet_service'      => :puppet_service,
     'puppet_modules'      => :puppet_modules,
     'puppet_module_repos' => :puppet_module_repos}
  end

  def create
    args = build_gcloud_args('create') + build_gcloud_flags(gcloud_optional_create_args)
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
      args << "name=#{resource[:boot_disk]},boot=yes"
    end
  end

  def append_metadata_args(args, resource)
    if has_metadata_args?(resource)
      metadata_args = []
      if resource[:metadata]
        resource[:metadata].each do |k, v|
          metadata_args << "#{k}=#{v}"
        end
      end
      puppet_metadata.each do |k, v|
        metadata_args << "#{k}=#{resource[v]}" if resource[v]
      end
      args << '--metadata'
      args << metadata_args.join(',')
    end
  end

  def append_startup_script_args(args, resource)
    if resource[:startup_script] or resource[:puppet_manifest]
      metadata_args = []
      if resource[:startup_script]
        startup_script_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'files', "#{resource[:startup_script]}"))
        metadata_args << "startup-script=#{startup_script_file}"
      end
      if resource[:puppet_manifest]
        puppet_manifest_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'files', "#{resource[:puppet_manifest]}"))
        metadata_args << "puppet_manifest=#{puppet_manifest_file}"
      end
      args << '--metadata-from-file'
      args << metadata_args.join(',')
    end
  end

  def block_for_startup_script(resource)
    if resource[:block_for_startup_script]
      begin
        # NOTE if startup_script_timeout is nil, the block will run without timing out
        status = Timeout::timeout(resource[:startup_script_timeout]) do
          loop do
            break if gcloud(*build_gcloud_ssh_startup_script_check_args) =~ /Finished running startup script/
            sleep BLOCK_FOR_STARTUP_SCRIPT_INTERVAL
          end
        end
      rescue Timeout::Error
        fail('Timed out waiting for bootstrap script to execute')
      end
    end
  end

  def build_gcloud_ssh_startup_script_check_args
    ['compute', 'ssh', resource[:name]] + build_gcloud_flags(gcloud_args) + ['--command', 'tail /var/log/startupscript.log -n 1']
  end

  def has_metadata_args?(resource)
    resource[:metadata] or (puppet_metadata.values.map{ |v| resource[v] }.any?)
  end
end
