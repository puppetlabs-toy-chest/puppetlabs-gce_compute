require 'spec_helper'

describe Puppet::Type.type(:gce_firewallrule) do
  let(:params) { [:name,
                  :description,
                  :allow,
                  :network,
                  :source_ranges,
                  :source_tags,
                  :target_tags] }

  it "should have expected parameters" do
    expect(described_class.parameters).to match_array(params + [:provider])
  end

  it "should be invalid without a name" do
    expect { described_class.new({}) }.to raise_error(/Title or name/)
  end

  it "should be invalid with an invalid name" do
    expect { described_class.new({:name => 'invalid-name-'}) }.to raise_error(/Invalid name/)
  end
end
