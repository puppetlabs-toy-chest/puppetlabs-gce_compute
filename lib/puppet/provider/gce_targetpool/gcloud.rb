require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_targetpool).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
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
end
