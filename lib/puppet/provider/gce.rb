require 'fog'
require 'google/api_client'
require 'google/api_client/auth/compute_service_account'

#TODO: Implement flush. This can then be used to get around the whole
# 'extra_args' issue seen in create by having each object keep track of the
# 'should' values in its own personal data structure. This will also allow
# resources to be updated with new settings where possible.
class Puppet::Provider::Gce < Puppet::Provider

  HAS_FOG = begin; require 'fog'; true; rescue Exception; false; end
  HAS_GOOG = begin; require 'google-api-client'; true; rescue Exception; false; end

  confine :true => HAS_FOG and HAS_GOOG

  # assignment of variables from gce_auth type for use in authentication
  class << self
    attr_accessor :project
    attr_accessor :key_file
    attr_accessor :client_email
  end

  @@connection = nil

  def self.connection
    self.create_connection unless @@connection
    @@connection
  end

  # TODO: Move creating the api client and compute service accounts into fog
  # so that it support internal metadata server authentication
  def self.create_connection
    require 'puppet/util/network_device/config'

    # Attempt to set project from certname if given and auth not already done.
    # This will use the internal metadata server for authentication if possible
    if not Puppet::Provider::Gce.project
      device = Puppet::Util::NetworkDevice::Config.devices[Puppet[:certname]]
      if device
        Puppet::Provider::Gce.project = device.url.split(':')[1]
        Puppet::Util::Warnings.warnonce('Using certname is deprecated. Please put ' \
                                  'gce_auth {<project name>:} in your manifest')
      end
    end
    raise(Puppet::Error, 'No project found. Did you add gce_auth to your ' \
      'manifest?') unless Puppet::Provider::Gce.project
    # TODO: move the api / oauth client creation into fog create API client
    client = ::Google::APIClient.new(
      :application_name => 'suppress warning',
      :user_agent => 'gce_compute/'
    )
    # create oauth 2 client, fetch token and assign it to API client
    oauthClient = ::Google::APIClient::ComputeServiceAccount.new()
    client.authorization = oauthClient
    client.authorization.fetch_access_token!
    @@connection = Fog::Compute.new({:provider => 'google',
                              :google_client => client,
                              :google_project => Puppet::Provider::Gce.project})
  end

  # general fog call, calls more specific fog actions
  # 'subtype' is specfic to resource on which the action is called
  # args is a hash of fog arguments
  def self.fog_call(action, *args)
    begin
      subtype.method(action).call(*args)
    rescue => e
      raise(Puppet::Error, e)
    end
  end

  def fog_call(action, *args)
    self.class.fog_call(action, *args)
  end

  # general create that calls create methods in subclasses then creates the
  # resource
  def create
    # 'extra_args' ensures that any inconsistancies between fog and puppet do
    # not cause errors
    # from mismatched resource names 
    # TODO: make sure that extra args != resource some how. Some init_create
    # methods end up returning resource which is then merged with itself...
    extra_args = {}
    # init_create is a method in the subclass of some resources if extra
    # arguments are needed
    extra_args = init_create if self.class.method_defined? :init_create
    rsrc = resource.to_hash
    rsrc.merge!(extra_args) if extra_args
    temp = fog_call(:create, rsrc)
    @property_hash = self.class.get_property_hash_content(temp)
    @@resource_cache[self.class.resource_type.name][resource[:name]] = temp
    
    # Wait for resource to be created if syncronous create is enabled
    # Use fetch with default true so that types that don't define the ready?
    # method default to being async operations
    temp.wait_for { temp.ready? } unless resource.to_hash.fetch(:async_create,
                                                                true)
  end

  # retrieve item from cache and call destroy
  # async is set in manifest file
  def destroy
    item = self.class.get_cache[self.class.resource_type.name][resource[:name]]
    item.destroy(async = resource[:async_destroy])

    # Update property_hash for puppet and clean our personal fog item cache
    self.class.get_cache.delete(resource[:name])
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  @@resource_cache = {}

  def self.get_cache
    @@resource_cache
  end

  # retrieves the content of the property cache from the resource attributes
  # used by the self.instances method
  def self.get_property_hash_content(rsrc)
    temp = {}
    params = parameter_list
    params << :name
    attribs = rsrc.attributes
    # This is really hacky, but we either have a class or an instance of a
    # class and the only place it matters is the temp[param] line below
    curClass = self.class == Class ? self : self.class
    params.each {|param|
      temp[param] = attribs[param] or \
        curClass.method_defined?(:puppet_fog_mappings) ? \
        attribs[puppet_fog_mappings(param)] : nil
    }
    temp[:ensure] = :present
    temp
  end

  # TODO: possible: do lazy eval called by puppet once for each resource type.
  # allows puppet to create the @property_hash.
  # class variable resource_cache hash is created mapping fog resource types
  # to hashes of resource names mapped to their fog objects.
  def self.instances
    queryResults = fog_call(:all)
    result = []
    @@resource_cache[self.resource_type.name] = {}
    queryResults.each {| rsrc |
      temp = get_property_hash_content(rsrc)
      result << new(temp)
      @@resource_cache[self.resource_type.name][rsrc.name] = rsrc
    }
    result
  end

  def self.prefetch(resources)
    instances.each {|prov|
      if resource = resources[prov.name] then
        resource.provider = prov
      end
    }
  end
end
