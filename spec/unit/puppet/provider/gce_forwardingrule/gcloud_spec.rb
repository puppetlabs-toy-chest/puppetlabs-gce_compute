require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_forwardingrule).provider(:gcloud) do
  let(:base_params) { {:name => 'name', :region => 'us-central1'} }
  let(:additional_params) { {} }
  let(:resource) { Puppet::Type.type(:gce_forwardingrule).new(base_params.merge(additional_params)) }
  let(:provider) { resource.provider }
  let(:gcloud_base_params) { ['compute', 'forwarding-rules', 'create', 'name', '--region', 'us-central1'] }
  let(:gcloud_additional_params) { [] }

  it_behaves_like "a resource that can be created"

  context "with an address" do
    let(:additional_params) { {:address => 'test-address'} }
    let(:gcloud_additional_params) { ['--address', '0.0.0.0'] }

    it "should return nil when a resource is created" do
      expect(provider).to receive(:gcloud).with('compute', 'addresses', 'describe', 'test-address', '--region', 'us-central1', '--format', 'json').and_return('{ "address": "0.0.0.0" }')
      expect(provider).to receive(:gcloud).with(*gcloud_base_params + gcloud_additional_params)
      expect(provider.create).to be_nil
    end

    it "should raise an exception when it can't find the address" do
      expect(provider).to receive(:gcloud).with('compute', 'addresses', 'describe', 'test-address', '--region', 'us-central1', '--format', 'json').and_raise(Puppet::ExecutionFailure.new(''))
      expect { provider.create }.to raise_error(Puppet::ExecutionFailure)
    end
  end
end
