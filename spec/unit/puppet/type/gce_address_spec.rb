require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_address) do
  let(:params) { [:name,
                  :region,
                  :description] }
  let(:create_params) { {:name => 'name', :region => 'region'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"

  it "should be invalid without a region" do
    expect { described_class.new({:name => 'name'}) }.to raise_error(/region/)
  end
end
