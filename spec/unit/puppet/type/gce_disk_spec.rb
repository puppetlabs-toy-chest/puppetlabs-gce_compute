require 'puppet'
require 'spec_helper'

describe Puppet::Type.type(:gce_disk) do
  let(:params) { [:name,
                  :zone,
                  :description,
                  :size,
                  :image] }

  it "should have expected parameters" do
    expect(described_class.parameters).to match_array(params + [:provider])
  end

  it "should be invalid without a name" do
    expect { described_class.new({:zone => 'zone'}) }.to raise_error(/name/)
  end

  it "should be invalid without a zone" do
    expect { described_class.new({:name => 'name'}) }.to raise_error(/zone/)
  end

  it "should be invalid with an invalid name" do
    expect { described_class.new({:name => 'invalid-name-',
                                  :zone => 'zone'}) }.to raise_error(/name/)
  end
end
