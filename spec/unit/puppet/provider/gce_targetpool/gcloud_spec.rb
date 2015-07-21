require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_targetpool).provider(:gcloud) do
  let(:base_params) { {:name => 'name', :region => 'us-central1'} }
  let(:additional_params) { {} }
  let(:resource) { Puppet::Type.type(:gce_targetpool).new(base_params.merge(additional_params)) }
  let(:provider) { resource.provider }
  let(:gcloud_base_params) { ['compute', 'target-pools', 'create', 'name', '--region', 'us-central1'] }
  let(:gcloud_additional_params) { [] }

  it_behaves_like "a resource that can be created"

  context "with instances" do
    let(:additional_params) { {:instances => {'us-central1-f' => ['instance1','instance2']}} }

    it "should return nil when a resource is created" do
      expect(provider).to receive(:gcloud).with(*gcloud_base_params + gcloud_additional_params)
      expect(provider).to receive(:gcloud).with('compute', 'target-pools', 'add-instances', 'name', '--zone', 'us-central1-f', '--instances', 'instance1,instance2')
      expect(provider.create).to be_nil
    end

    it "should raise an exception when it can't find the address" do
      expect(provider).to receive(:gcloud).with(*gcloud_base_params + gcloud_additional_params)
      expect(provider).to receive(:gcloud).with('compute', 'target-pools', 'add-instances', 'name', '--zone', 'us-central1-f', '--instances', 'instance1,instance2').and_raise(Puppet::ExecutionFailure.new(''))
      expect { provider.create }.to raise_error(Puppet::ExecutionFailure)
    end
  end
end
