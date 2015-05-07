require 'puppet'
require 'spec_helper'

describe Puppet::Type.type(:gce_httphealthcheck) do
  let(:params) { [:name,
                  :description,
                  :check_interval,
                  :timeout,
                  :healthy_threshold,
                  :host,
                  :port,
                  :request_path,
                  :unhealthy_threshold] }

  it "should have expected parameters" do
    expect(described_class.parameters).to match_array(params + [:provider])
  end

  it "should be invalid without a name" do
    expect { described_class.new({}) }.to raise_error(/name/)
  end

  it "should be invalid with an invalid name" do
    expect { described_class.new({:name => 'invalid-name-'}) }.to raise_error(/name/)
  end
end
