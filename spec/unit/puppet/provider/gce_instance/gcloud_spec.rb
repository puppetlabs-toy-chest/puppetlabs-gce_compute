require 'spec_helper'

describe Puppet::Type.type(:gce_instance).provider(:gcloud) do
  let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                        :zone => 'us-central1-a') }
  let(:provider) { resource.provider }
  let(:required_params) { ['compute', 'instances', 'create', 'name', '--zone', 'us-central1-a'] }

  describe "create" do
    it "should return nil when a resource is created" do
      expect(provider).to receive(:gcloud).with(*required_params)
      expect(provider.create).to be_nil
    end

    it "should raise an exception when the resource already exists" do
      expect(provider).to receive(:gcloud).with(*required_params).and_raise(Puppet::ExecutionFailure.new(''))
      expect { provider.create }.to raise_error(Puppet::ExecutionFailure)
    end
  end

  context "with can_ip_forward" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :can_ip_forward => true) }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--can-ip-forward'])
        expect(provider.create).to be_nil
      end
    end
  end

  context "with boot_disk" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :boot_disk => 'disk') }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--disk', 'name=disk', 'boot=yes'])
        expect(provider.create).to be_nil
      end
    end
  end

  context "with can_ip_forward" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :metadata => {'test-metadata-key' => 'test-metadata-value'}) }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata', 'test-metadata-key=test-metadata-value'])
        expect(provider.create).to be_nil
      end
    end
  end

  context "with can_ip_forward" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :startup_script => '../examples/gce_instance/example-startup-script.sh') }
    describe "create" do
      it "should return nil when a resource is created" do
        startup_script_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'files', "#{resource[:startup_script]}"))
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata-from-file', "startup-script=#{startup_script_file}"])
        expect(provider.create).to be_nil
      end
    end
  end
end
