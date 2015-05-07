require 'spec_helper'
require 'puppet/provider/gcloud'

describe Puppet::Provider::Gcloud do
  let(:resource) { Puppet::Type.type(:gce_fake).new(:name => 'fake-name',
                                                    :zone => 'us-central1-a',
                                                    :description => 'Fake description',
                                                    :source => 'source-place') }
  let(:provider) { resource.provider }
  let(:required_params) { ['compute', 'fakes', 'fake-name', '--zone', 'us-central1-a'] }
  let(:optional_params) { ['--description', 'Fake description', '--source', 'source-place'] }

  def required_params_with(action)
    required_params.insert(2, action)
  end

  describe "#exists?" do
    it "should return true when a resource is found" do
      expect(provider).to receive(:gcloud).with(*required_params_with('describe'))
      expect(provider.exists?).to eq(true)
    end

    it "should return false when no resource is found" do
      expect(provider).to receive(:gcloud).with(*required_params_with('describe')).and_raise(Puppet::ExecutionFailure.new(''))
      expect(provider.exists?).to eq(false)
    end
  end

  describe "create" do
    it "should return nil when a resource is created" do
      expect(provider).to receive(:gcloud).with(*required_params_with('create')+optional_params)
      expect(provider.create).to be_nil
    end

    it "should raise an exception when the resource already exists" do
      expect(provider).to receive(:gcloud).with(*required_params_with('create')+optional_params).and_raise(Puppet::ExecutionFailure.new(''))
      expect { provider.create }.to raise_error(Puppet::ExecutionFailure)
    end

  end

  describe "destroy" do
    it "should return nil when a resource is destroyed" do
      expect(provider).to receive(:gcloud).with(*required_params_with('delete'))
      expect(provider.destroy).to be_nil
    end

    it "should raise an exception when the resource already exists" do
      expect(provider).to receive(:gcloud).with(*required_params_with('delete')).and_raise(Puppet::ExecutionFailure.new(''))
      expect { provider.destroy }.to raise_error(Puppet::ExecutionFailure)
    end
  end

  context "with an invalid resource" do
    let(:resource) { Puppet::Type.type(:gce_fake).new(:name => 'fake-name',
                                                      :zone => 'us-central1-a',
                                                      :description => 'Invalid fake description',
                                                      :source => 'invalid-source-place') }
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

# Fakes

Puppet::Type.newtype(:gce_fake) do

  desc 'A fake gce resource'

  ensurable

  newparam(:name, :namevar => true)

  # required params
  newparam(:zone)

  # optional params
  newparam(:description)
  newparam(:source)

  validate do
    fail('You must specify a zone for the fake') unless self[:zone]
  end
end

Puppet::Type.type(:gce_fake).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'fakes'
  end

  # These arguments are required for both create and destroy
  # TODO refactor these to look the same as the optional args
  def gcloud_args
    ['--zone', resource[:zone]]
  end

  def gcloud_optional_create_args
    {:description => '--description',
     :source => '--source'}
  end
end
