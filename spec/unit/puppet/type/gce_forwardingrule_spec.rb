require 'puppet'
require 'spec_helper'

describe Puppet::Type.type(:gce_forwardingrule) do
  let(:params) { [:name,
                  :region,
                  :description,
                  :ip_protocol,
                  :port_range,
                  :target_pool,
                  :ip] }

  it "should have expected parameters" do
    expect(described_class.parameters).to match_array(params + [:provider])
  end

  it "should be invalid without a name" do
    expect { described_class.new({:region => 'region'}) }.to raise_error(/name/)
  end

  it "should be invalid without a region" do
    expect { described_class.new({:name => 'name'}) }.to raise_error(/region/)
  end

  it "should be invalid with an invalid name" do
    expect { described_class.new({:name => 'invalid-name-',
                                               :region => 'region'}) }.to raise_error(/name/)
  end

  it "should be invalid with an invalid protocol" do
    expect { described_class.new({:name => 'name',
                                  :region => 'region',
                                  :ip_protocol => 'NOPE'}) }.to raise_error(/protocol/)
  end
end
