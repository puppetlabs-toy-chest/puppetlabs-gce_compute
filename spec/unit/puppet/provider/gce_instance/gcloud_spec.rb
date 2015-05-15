require 'spec_helper'

describe Puppet::Type.type(:gce_instance).provider(:gcloud) do
  let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                        :zone => 'us-central1-a') }
  let(:provider) { resource.provider }
  let(:required_params) { ['compute', 'instances', 'create', 'name', '--zone', 'us-central1-a'] }
  let(:startup_script_file) { File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'files', "#{resource[:startup_script]}")) }
  let(:puppet_manifest_file) { File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'files', "#{resource[:puppet_manifest]}")) }

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

  context "with metadata" do
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

  context "with startup_script" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :startup_script => '../examples/gce_instance/example-startup-script.sh') }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata-from-file', "startup-script=#{startup_script_file}"])
        expect(provider.create).to be_nil
      end
    end
  end

  context "with block_for_startup_script" do
    let(:ssh_params) { ['compute', 'ssh', 'name', '--zone', 'us-central1-a', '--command', 'tail /var/log/startupscript.log -n 1'] }
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :startup_script => '../examples/gce_instance/example-startup-script.sh',
                                                          :block_for_startup_script => true) }

    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata-from-file', "startup-script=#{startup_script_file}"])
        expect(provider).to receive(:gcloud).with(*ssh_params).exactly(3).times.and_return('Not done', 'Still not done', 'Finished running startup script')
        expect(provider).to receive(:sleep).exactly(2).times.and_return(nil)
        expect(provider.create).to be_nil
      end
    end

    context "and with a startup_script_timeout" do
      let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                            :zone => 'us-central1-a',
                                                            :startup_script => '../examples/gce_instance/example-startup-script.sh',
                                                            :block_for_startup_script => true,
                                                            :startup_script_timeout => 0.001) }
      describe "create" do
        it "should raise an error when a resource is created because the timeout is reached" do
          expect(provider).to receive(:gcloud).with(*required_params + ['--metadata-from-file', "startup-script=#{startup_script_file}"])
          expect(provider).to receive(:gcloud).with(*ssh_params) { sleep 1 }
          expect { provider.create }.to raise_error(Puppet::Error)
        end
      end
    end
  end

  context "with puppet_master" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :puppet_master => 'master-blaster') }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata', 'puppet_master=master-blaster'])
        expect(provider.create).to be_nil
      end
    end
  end

  context "with puppet_service" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :puppet_service => 'present') }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata', 'puppet_service=present'])
        expect(provider.create).to be_nil
      end
    end
  end

  context "with puppet_manifest" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :puppet_manifest => '../examples/gce_instance/example-puppet-manifest.pp') }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata-from-file', "puppet_manifest=#{puppet_manifest_file}"])
        expect(provider.create).to be_nil
      end
    end
  end

  context "with puppet_modules" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :puppet_modules => ['puppetlabs-gce_compute','puppetlabs-mysql']) }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata', "puppet_modules=puppetlabs-gce_compute puppetlabs-mysql"])
        expect(provider.create).to be_nil
      end
    end
  end

  context "with puppet_module_repos" do
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-a',
                                                          :puppet_module_repos => {'puppetlabs-gce_compute' => 'git://github.com/puppetlabs/puppetlabs-gce_compute',
                                                                                   'puppetlabs-mysql' => 'git://github.com/puppetlabs/puppetlabs-mysql'}) }
    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*required_params + ['--metadata', "puppet_module_repos=git://github.com/puppetlabs/puppetlabs-gce_compute#puppetlabs-gce_compute git://github.com/puppetlabs/puppetlabs-mysql#puppetlabs-mysql"])
        expect(provider.create).to be_nil
      end
    end
  end
end
