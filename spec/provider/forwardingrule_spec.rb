require 'spec_helper'

provider_class = Puppet::Type.type(:gce_forwardingrule).provider(:fog)

  describe provider_class do
  
  context '#init_create' do 
    let (:provider) { provider_class.new(:name => 'test-rule') }

    it 'will specify target pool if only that is given' do
      
      pool = double("test-pool", :self_link => 'pool')
      pool_lst = { 'test-pool' => pool }
      property_cache = { :gce_targetpool => pool_lst, :gce_forwardingrule => {} }
      provider_class.superclass.class_variable_set(:@@resource_cache, property_cache)
      provider.resource = {:target => 'test-pool'}
      provider.init_create
      expect(provider.resource[:target]).to eq 'pool'
    end

    it 'raises error if target pool doesnt exist' do
  
      pool = double("test-pool", :self_link => 'pool')
      pool_lst = { 'test-pool' => pool }
      property_cache = { :gce_targetpool => pool_lst, :gce_forwardingrule => {} }
      provider_class.superclass.class_variable_set(:@@resource_cache, property_cache)
      
      provider.resource = {:target => 'test-pool-fake'}
      expect {provider.init_create}.to raise_error(Puppet::Error, /target pool specified for forwarding rule does not exist/)
     end

    it 'raises error if no target pool specified' do
  
      pool = double("test-pool", :self_link => 'pool')
      pool_lst = { 'test-pool' => pool }
      property_cache = { :gce_targetpool => pool_lst, :gce_forwardingrule => {} }
      provider_class.superclass.class_variable_set(:@@resource_cache, property_cache)
      
      provider.resource = {}
      expect {provider.init_create}.to raise_error(Puppet::Error, /Target pool must be specified for forwarding rules/)
     end
  end
end
