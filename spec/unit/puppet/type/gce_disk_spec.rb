require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_disk) do
  let(:params) { [:name,
                  :zone,
                  :description,
                  :size,
                  :image] }
  let(:create_params) { {:name => 'name', :zone => 'zone'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"

  it "should be invalid without a zone" do
    create_params[:zone] = nil
    expect { described_class.new(create_params) }.to raise_error(/zone/)
  end
end
