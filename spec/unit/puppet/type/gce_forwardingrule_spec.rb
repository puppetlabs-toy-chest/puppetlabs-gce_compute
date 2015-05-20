require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_forwardingrule) do
  let(:params) { [:name,
                  :region,
                  :description,
                  :address,
                  :ip_protocol,
                  :port_range,
                  :target_pool] }
  let(:create_params) { {:name => 'name', :region => 'region'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"

  it "should be invalid without a region" do
    expect { described_class.new({:name => 'name'}) }.to raise_error(/region/)
  end

  it "should be invalid with an invalid protocol" do
    expect { described_class.new({:name => 'name',
                                  :region => 'region',
                                  :ip_protocol => 'NOPE'}) }.to raise_error(/protocol/)
  end
end
