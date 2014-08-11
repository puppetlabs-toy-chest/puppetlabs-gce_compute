require 'spec_helper'

describe Puppet::Type::type(:gce_auth) do
  context 'when only project name given' do
    let(:resource) { Puppet::Type.type(:gce_auth).new(
      :project => 'test-project-9000',
      :ensure => 'present'
    )}

    it 'project is set' do
      expect(resource[:project]).to eq 'test-project-9000'
    end

    it 'name is set to project' do
      expect(resource[:name]).to eq 'test-project-9000'
    end

    it 'ensure is present' do
      expect(resource[:ensure]).to eq :present
    end

    it 'client email is not set' do
      expect(resource[:client_email]).to eq nil
    end

    it 'key file is not set' do
      expect(resource[:key_file]).to eq nil
    end

  end

  context 'when an invalid project is given' do

    it 'raises an error' do
      expect{Puppet::Type.type(:gce_auth).new(
        :project => '@test-project_9000',
        :ensure => 'present'
      )}.to raise_error(Puppet::Error, /Invalid project name/)
    end
  end

  context 'when project, service email, and keyfile given' do
    let(:resource) { Puppet::Type.type(:gce_auth).new(
      :project => 'test-project-9000',
      :ensure => 'present',
      :client_email => 'someemailname@developer.gserviceaccount.com',
      :key_file => '/path/to/some/locations/key.p12'
    )}

    it 'project is set' do
      expect(resource[:project]).to eq 'test-project-9000'
    end

    it 'name is set to project' do
      expect(resource[:name]).to eq 'test-project-9000'
    end

    it 'ensure is present' do
      expect(resource[:ensure]).to eq :present
    end

    it 'client email is set' do
      expect(resource[:client_email]).to eq \
        'someemailname@developer.gserviceaccount.com'
    end

    it 'key file is set' do
      expect(resource[:key_file]).to eq '/path/to/some/locations/key.p12'
    end
  end
end
