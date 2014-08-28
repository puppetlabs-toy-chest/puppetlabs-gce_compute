require 'spec_helper'

type = Puppet::Type::type(:gce_targetpool)

describe type do
  context 'when name is invalid' do
    
    it 'raises an error' do
      expect{ type.new(
          :name => '!!!'
          )}.to raise_error(Puppet::ResourceError, /Invalid targetpool name/)
    end
  end

  end
