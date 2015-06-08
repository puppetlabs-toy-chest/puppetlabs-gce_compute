require 'spec_helper'
require 'helpers/unit_spec_helper'
require 'puppet/provider/gcloud'

describe Puppet::Provider::Gcloud do
  let(:base_params) { {:name => 'name', :zone => 'us-central1-f'} }
  let(:additional_params) { {} }
  let(:resource) { Puppet::Type.type(:gce_fake).new(base_params.merge(additional_params)) }
  let(:provider) { resource.provider }
  let(:gcloud_base_params) { ['compute', 'fakes', 'create', 'name', '--zone', 'us-central1-f'] }
  let(:gcloud_additional_params) { [] }

  def required_params_with(action)
    gcloud_base_params[2] = action
    return gcloud_base_params
  end

  it_behaves_like "a resource that can be created"

  context "with extra params" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:source => 'source', :tags => ['t1', 't2']} }
      let(:gcloud_additional_params) { ['--source', 'source', '--tags', 't1,t2'] }
    end
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
                                                      :zone => 'us-central1-f',
                                                      :description => 'Invalid fake description',
                                                      :source => 'invalid-source-place',
                                                      :tags => []) }
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
  newparam(:tags)

  validate do
    fail('You must specify a zone for the fake') unless self[:zone]
  end
end

Puppet::Type.type(:gce_fake).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  confine :gcloud_compatible_version => true
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'fakes'
  end

  def gcloud_args
    {:zone => '--zone'}
  end

  def gcloud_optional_create_args
    {:description => '--description',
     :source => '--source',
     :tags => '--tags'}
  end
end
