require 'spec_helper'

type = Puppet::Type::type(:gce_httphealthcheck)

describe type do
  context 'when name is invalid' do

    it 'raises an error' do
      expect{ type.new(
          :name => '!!!!!'
          )}.to raise_error(Puppet::ResourceError, /Invalid httphealthcheck name/)
    end
  end

  context 'when ensure present' do

    it 'raises an error when invalid interval specified' do
      expect{type.new(
          :name =>'test',
          :ensure => :present,
          :check_interval_sec => 'a'
          )}.to raise_error(Puppet::Error, /Check interval needs to be integer seconds greater than zero a/)
      end

    it 'raises an error when invalid timeout specified' do
      expect{type.new(
          :name =>'test',
          :ensure => :present,
          :check_timeout_sec => 'a'
          )}.to raise_error(Puppet::Error, /Check timeout needs to be integer seconds greater than zero a/)
      end

    it 'raises an error when invalid port specified' do
      expect{type.new(
          :name =>'test',
          :ensure => :present,
          :port => 'a',
          )}.to raise_error(Puppet::Error, /The port must be an integer greater than zero a/)
    end

    it 'raises an error when invalid request path specified' do
      expect{type.new(
          :name =>'test',
          :ensure => :present,
          :request_path => 'a',
          )}.to raise_error(Puppet::ResourceError, /Request path must start with/)
    end


    it 'raises an error when invalid unhealthy threshold specified' do
      expect{type.new(
          :name =>'test',
          :ensure => :present,
          :unhealthy_threshold => 'a',
          )}.to raise_error(Puppet::ResourceError, /Unhealthy threshold must/)
    end
  end

  context 'when everything is set correctly' do
    let(:resource) {type.new(
        :ensure => :present,
        :name => 'test-check',
        :check_interval_sec => 1,
        :check_timeout_sec => 1,
        :description => 'test',
        :healthy_threshold => 1,
        :host => 'test_host',
        :port => 80,
        :request_path => '/',
        :unhealthy_threshold => 1,
        )}
    it 'name is set' do
      expect(resource[:name]).to eq 'test-check'
    end


    it 'check interval sec is set' do
      expect(resource[:check_interval_sec]).to eq 1
    end
    
    it 'check_timeout_sec is set' do
      expect(resource[:check_timeout_sec]).to eq 1
    end
    
    it 'description is set' do
      expect(resource[:description]).to eq 'test'
    end
    
    it 'healthy_threshold is set' do
      expect(resource[:healthy_threshold]).to eq 1
    end
    
    it 'host is set' do
      expect(resource[:host]).to eq 'test_host'
    end
    
    it 'port is set' do
      expect(resource[:port]).to eq 80
    end
    
    it 'request_path is set' do
      expect(resource[:request_path]).to eq '/'
    end
    
    it 'unhealthy threshold is set' do
      expect(resource[:unhealthy_threshold]).to eq 1
    end
    
    it 'async_create is defaulted to false' do
      expect(resource[:async_create]).to eq false
    end
    
    it 'async_destroy is defaulted to false' do
      expect(resource[:async_destroy]).to eq false
    end
end
context 'when required resources are set' do
    let(:resource) {type.new(
        :ensure => :present,
        :name => 'test-check',
        :async_create => true,
        :async_destroy => true,
        )}
    it 'async_create and destroy can be set to true' do
      expect(resource[:async_create]).to eq true
      expect(resource[:async_destroy]).to eq true
    end
  end
end
