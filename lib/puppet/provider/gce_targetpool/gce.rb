require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_targetpool).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  def self.subtype
    superclass.connection.target_pools
  end

  def subtype
    self.class.subcommand
  end

  def self.parameter_list
    [:description, :region, :health_checks, :instances, :session_affinity, :backup_pool, :failover_ratio, :async_destory, :async_create ]
  end

  def init_create
    # turn health_check strings into gce_health_check objects for fog
    instances = []
    if resource[:health_checks] then
     if self.class.get_cache[:gce_httphealthcheck][resource[:health_checks]] then
 resource[:health_checks] = [self.class.get_cache[:gce_httphealthcheck][resource[:health_checks]].self_link]  
      else
        raise(Puppet::Error, 'health check specified for target pool does not exist')
      end
    end
# turn instances into gce_instance objects for fog
    if resource[:instances] then
     resource[:instances].split(',').each do |insta| 
       name = insta.split('/')[1]
       if self.class.get_cache[:gce_instance][name] then
         instances << self.class.get_cache[:gce_instance][name].self_link 
       else 
         raise(Puppet::Error, 'specified instance for target pool does not exist')
       end
    end

    resource[:instances] = instances
    end
    resource

  end
end
