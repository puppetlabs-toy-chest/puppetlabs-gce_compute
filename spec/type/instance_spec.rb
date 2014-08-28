require 'spec_helper'

type = Puppet::Type::type(:gce_instance)

describe type do
  context 'when name is invalid' do

    it 'raises an error' do
      expect{type.new(
        :name => 'test-'
      )}.to raise_error(Puppet::Error, /Invalid instance name/)
    end
  end

  context 'when ensure present' do

    it 'raises an error when no machine type is given' do
      expect{type.new(
        :name => 'test-instance',
        :ensure => 'present',
        :zone => 'us-central1-a',
        :disk => 'test-disk'
      )}.to raise_error(Puppet::Error, /Did not specify required param machine_type/)
    end

    it 'raises an error when no disk or image is given' do
      expect{type.new(
        :name => 'test-instance',
        :ensure => 'present',
        :zone => 'us-central1-a',
        :machine_type => 'n1-standard-1'
      )}.to raise_error(Puppet::Error, /Did not specify required param image or disk/)
    end

    it 'raises an error when no zone is given' do
      expect{type.new(
        :name => 'test-instance',
        :ensure => 'present',
        :disk => 'test-disk',
        :machine_type => 'n1-standard-1'
      )}.to raise_error(Puppet::Error, /Did not specify required param zone/)
    end

  end

  it 'raises an error if puppet_service is given and not absent or present' do
    expect{type.new(
      :name => 'test-instance',
      :puppet_service => 'foo'
    )}.to raise_error(Puppet::Error, /Invalid value/)
  end



end
