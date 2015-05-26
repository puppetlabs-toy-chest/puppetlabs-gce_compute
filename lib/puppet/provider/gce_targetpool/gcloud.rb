require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_targetpool).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  confine :gcloud_compatible_version => true
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'target-pools'
  end

  # These arguments are required for both create and destroy
  def gcloud_args
    {:region => '--region'}
  end

  def gcloud_optional_create_args
    {:description      => '--description',
     :health_check     => '--health-check',
     :session_affinity => '--session-affinity',
     :backup_pool      => '--backup-pool',
     :failover_ratio   => '--failover-ratio'}
  end

  def create
    gcloud(*(build_gcloud_args('create') + build_gcloud_flags(gcloud_optional_create_args)))
    add_instances
    return nil
  end

  def add_instances
    if resource[:instances]
      resource[:instances].each do |zone, instances|
        # we should be able to do this with #build_gcloud_args,
        # but add_instances doesn't accept region, so we have to do it by hand
        gcloud('compute', gcloud_resource_name,
               'add-instances', resource[:name],
               '--zone', zone,
               '--instances', instances.join(','))
      end
    end
  end
end
