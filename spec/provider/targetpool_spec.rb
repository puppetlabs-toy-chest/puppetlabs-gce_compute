require 'spec_helper'

provider_class = Puppet::Type.type(:gce_targetpool).provider(:fog)
describe provider_class do
  
  context '#create' do
    let(:provider) { provider_class.new(
        :name => 'test-pool',
        :health_checks => 'test_check',
        :instances => 'us-central1-b/test-instance',
        :ensure => :present
      )}
    it '.create should set health checks and instance' do
  
      # populate cache
      check_one = double("test_check", :self_link => 'check_one')
      check = {'test_check' => check_one }
      instance_one = double("test-instance", :self_link => 'instance_one')
      instance_lst = { 'test-instance' => instance_one }
      property_cache = { :gce_httphealthcheck => check, :gce_instance => instance_lst, :gce_targetpool => {'some-pool'=> double('some-pool') } } 

      provider.resource = {
        :name => 'test-pool',
        :health_checks => 'test_check',
        :instances => 'us-central1-b/test-instance',
        :ensure => :present
      }
      # create mocks for the 'create' method
      fog = stub('fog')
      target_pools = stub('target_pools')
      created = stub('created')
      attributes = { :description => '', :region => 'us-central1-b', :health_checks => check_one, :instances => instance_one, :session_affinity => nil, :backup_pool => nil, :fallover_ratio => nil, :async_destroy => nil, :async_create => nil }
      provider_class.superclass.class_variable_set(:@@connection, fog)
      expect(fog).to receive(:target_pools).and_return(target_pools)
      expect(target_pools).to receive(:create).and_return(created)
      expect(created).to receive(:attributes).and_return(attributes)
      provider_class.superclass.class_variable_set(:@@resource_cache, property_cache)
inst =  provider.create
      expect(provider.resource[:name]).to eq 'test-pool'
      expect(provider.resource[:health_checks]).to eq ['check_one']
      expect(provider.resource[:instances]).to eq ['instance_one']
    end
   end  
 
  context '#init_create' do
    
    let(:provider) { provider_class.new(
        :name => 'test-pool',
      )}
    it 'init_create should throw an error if instance that does not exist is specified' do
  
      # populate cache
      check_one = double("test_check", :self_link => 'check_one')
      check = {'test_check' => check_one }
      instance_lst = { }
      property_cache = { :gce_httphealthcheck => check, :gce_instance => instance_lst, :gce_targetpool => {'some-pool'=> double('some-pool') }}
  
      provider_class.superclass.class_variable_set(:@@resource_cache, property_cache)
      provider.resource = {
        :name => 'test-pool',
        :health_checks => 'test_check',
        :instances => 'us-central1-b/test-instance',
        :ensure => :present
      }
    expect {provider.init_create}.to raise_error(Puppet::Error, /specified instance for target pool does not exist/)
    end  
    it 'resource[:instances] should be assigned to an array of self_links of the instances' do

      # populate cache
      check_one = double("test_check", :self_link => 'check_one')
      check = {'test_check' => check_one }
      instance_one = double("test-instance", :self_link => 'instance_one')
      instance_two = double("test-instance-two", :self_link => 'instance_two')
      instance_lst = { 'test-instance' => instance_one, 'test-instance-two' => instance_two }
      property_cache = { :gce_httphealthcheck => check, :gce_instance => instance_lst, :gce_targetpool => {'some-pool'=> double('some-pool') } } 

      provider_class.superclass.class_variable_set(:@@resource_cache, property_cache)
      provider.resource = {
        :name => 'test-pool',
        :health_checks => 'test_check',
        :instances => 'us-central1-b/test-instance, us-central1-b/test-instance-two',
        :ensure => :present
      }
    provider.init_create
    expect(provider.resource[:health_checks]).to eq ['check_one']
    expect(provider.resource[:instances]).to eq ['instance_one','instance_two']
  end

  it 'should throw an error if the specified health check does not exist' do

      check = { }
      instance_one = double("test-instance", :self_link => 'instance_one')
      instance_two = double("test-instance-two", :self_link => 'instance_two')
      instance_lst = { 'test-instance' => instance_one, 'test-instance-two' => instance_two }
      property_cache = { :gce_httphealthcheck => check, :gce_instance => instance_lst, :gce_targetpool => {'some-pool'=> double('some-pool') } } 

      provider_class.superclass.class_variable_set(:@@resource_cache, property_cache)
      provider.resource = {
        :name => 'test-pool',
        :health_checks => 'test_check',
        :instances => 'us-central1-b/test-instance, us-central1-b/test-instance-two',
        :ensure => :present
      }
    expect {provider.init_create}.to raise_error(Puppet::Error, /health check specified for target pool does not exist/)
  end
end
end
