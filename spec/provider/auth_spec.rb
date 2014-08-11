require 'spec_helper'

provider_class = Puppet::Type.type(:gce_auth).provider(:fog)

describe provider_class do

  context 'when only project is set' do
    let(:provider) { provider_class.new(
      :project => 'test-project-9000',
      :name => 'test-project-9000',
      :ensure => :present
    )}

    before(:each) {
      provider_class.superclass.instance_variable_set(:@project, nil)
      provider_class.superclass.instance_variable_set(:@client_email, nil)
      provider_class.superclass.instance_variable_set(:@key_file, nil)
    }

    it '.create should set project in Puppet::Provider::Gce' do
      provider.resource = {
        :project => 'test-project-9000',
        :name => 'test-project-9000',
        :ensure => :present
      }
      provider.create
      expect(provider.class.superclass.project).to eq 'test-project-9000'
      expect(provider.class.superclass.client_email).to eq nil
      expect(provider.class.superclass.key_file).to eq nil
    end
  end

  context 'when project, client email, and key file are set' do
    let(:provider) { provider_class.new(
      :project => 'test-project-9000',
      :name => 'test-project-9000',
      :ensure => :present,
      :client_email => 'someemailname@developer.gserviceaccount.com',
      :key_file => '/path/to/some/locations/key.p12'
    )}

    it '.create should set project, client email, and key in Puppet::Provider::Gce' do
      provider.resource = {
        :project => 'test-project-9000',
        :name => 'test-project-9000',
        :ensure => :present,
        :client_email => 'someemailname@developer.gserviceaccount.com',
        :key_file => '/path/to/some/locations/key.p12'
      }
      provider.create
      expect(provider.class.superclass.project).to eq 'test-project-9000'
      expect(provider.class.superclass.client_email).to eq \
        'someemailname@developer.gserviceaccount.com'
      expect(provider.class.superclass.key_file).to eq \
        '/path/to/some/locations/key.p12'
    end
  end

end

