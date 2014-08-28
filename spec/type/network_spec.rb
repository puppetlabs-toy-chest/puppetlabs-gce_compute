require 'spec_helper'

type = Puppet::Type::type(:gce_network)
describe type do
  it 'raises an error when the name is too long' do
      expect{type.new(:name => 'test-test-test-test-test-test-test-test-test-test-test-test-1111'
      )}.to raise_error(Puppet::Error, /Invalid network name/)
  end

  it 'raises an error when the last character of the name is a \'-\'' do
      expect{type.new(:name => 'test-')}.to raise_error(Puppet::Error, /Invalid network name/)
  end


  it 'raises an error when the name has special characters' do
      expect{type.new(:name => 'test@')}.to raise_error(Puppet::Error, /Invalid network name/)
  end

  it 'raises an error when the gateway is invalid' do
      expect{type.new(:name => 'test', :gateway => '100.')}.to raise_error(Puppet::Error, /Invalid gateway IP address/)
  end

  it 'raises an error when the range is invalid' do
      expect{type.new(:name => 'test', :range => '1.1.1.1/123')}.to raise_error(Puppet::Error, /Invalid network range/)
  end
end
