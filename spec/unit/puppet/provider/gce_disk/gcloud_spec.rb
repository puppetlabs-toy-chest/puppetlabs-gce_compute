require 'spec_helper'

describe Puppet::Type.type(:gce_disk).provider(:gcloud) do
  let(:resource) { Puppet::Type.type(:gce_disk).new(:name => 'disk1',
                                                    :zone => 'us-central1-a') }
  let(:provider) { resource.provider }


  let(:params) { ['compute', 'disks', 'disk1', '--zone', 'us-central1-a'] }

  def params_with(action)
    params.insert(2, action)
  end

  describe "#exists?" do
    it "should return true when a resource is found" do
      expect(provider).to receive(:gcloud).with(*params_with('describe'))
      expect(provider.exists?).to eq(true)
    end

    it "should return false when no resource is found" do
      expect(provider).to receive(:gcloud).with(*params_with('describe')).and_raise(Puppet::ExecutionFailure.new(''))
      expect(provider.exists?).to eq(false)
    end
  end

  describe "create" do
    it "should return nil when a resource is created" do
      expect(provider).to receive(:gcloud).with(*params_with('create'))
      expect(provider.create).to be_nil
    end

    it "should raise an exception when the resource already exists" do
      expect(provider).to receive(:gcloud).with(*params_with('create')).and_raise(Puppet::ExecutionFailure.new(''))
      expect { provider.create }.to raise_error(Puppet::ExecutionFailure)
    end

  end

  describe "destroy" do
    it "should return nil when a resource is destroyed" do
      expect(provider).to receive(:gcloud).with(*params_with('delete'))
      expect(provider.destroy).to be_nil
    end

    it "should raise an exception when the resource already exists" do
      expect(provider).to receive(:gcloud).with(*params_with('delete')).and_raise(Puppet::ExecutionFailure.new(''))
      expect { provider.destroy }.to raise_error(Puppet::ExecutionFailure)
    end
  end

  context "with an invalid resource" do
    let(:resource) { Puppet::Type.type(:gce_disk).new(:name => 'invalid-disk') }
    let(:provider) { resource.provider }

    describe "#exists?" do
      it "should return false when given an invalid resource" do
        expect(provider).to receive(:gcloud).and_raise(Puppet::ExecutionFailure.new(''))
        expect(provider.exists?).to eq(false)
      end
    end

    describe "create" do
      it "should raise an exception when the resource is invalid" do
        expect(provider).to receive(:gcloud).and_raise(Puppet::ExecutionFailure.new(''))
        expect { provider.create }.to raise_error(Puppet::ExecutionFailure)
      end
    end

    describe "destroy" do
      it "should raise an exception when the resource is invalid" do
        expect(provider).to receive(:gcloud).and_raise(Puppet::ExecutionFailure.new(''))
        expect { provider.destroy }.to raise_error(Puppet::ExecutionFailure)
      end
    end
  end
end
