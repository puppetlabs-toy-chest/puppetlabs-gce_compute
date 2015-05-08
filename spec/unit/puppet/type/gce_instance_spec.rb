require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_instance) do
  let(:params) { [:name,
                  :zone,
                  :can_ip_forward,
                  :description,
                  :boot_disk,
                  :image,
                  :machine_type,
                  :metadata,
                  :network,
                  :maintenance_policy,
                  :startup_script,
                  :tags] }
  let(:create_params) { {:name => 'name', :zone => 'zone'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"

  it "should be invalid without a zone" do
    expect { described_class.new({:name => 'name'}) }.to raise_error(/zone/)
  end
end
