require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_instance).provider(:gcloud) do
  let(:base_params) { {:name => 'name', :zone => 'us-central1-f'} }
  let(:additional_params) { {} }
  let(:resource) { Puppet::Type.type(:gce_instance).new(base_params.merge(additional_params)) }
  let(:provider) { resource.provider }
  let(:gcloud_base_params) { ['compute', 'instances', 'create', 'name', '--zone', 'us-central1-f'] }
  let(:gcloud_additional_params) { [] }
  let(:startup_script_file) { File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'files', "#{resource[:startup_script]}")) }
  let(:puppet_manifest) { <<EOS
# install apache2 package and serve a page
class examples ($version = 'latest') {
  package {'apache2':
    ensure => $version, # Using the class parameter from above
  }
  file {'/var/www/index.html':
    ensure  => present,
    content => 'Pinocchio says hello!',
    require => Package['apache2'],
  }
  service {'apache2':
    ensure  => running,
    enable  => true,
    require => File['/var/www/index.html'],
  }
}
include examples
EOS
}

  it_behaves_like "a resource that can be created"

  context "with can_ip_forward" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:can_ip_forward => true} }
      let(:gcloud_additional_params) { ['--can-ip-forward'] }
    end
  end

  context "with boot_disk" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:boot_disk => 'disk'} }
      let(:gcloud_additional_params) { ['--disk', 'name=disk,boot=yes'] }
    end
  end

  context "with metadata" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:metadata => {'key1' => 'value1', 'key2' => 'value2'}} }
      let(:gcloud_additional_params) { ['--metadata', '^-zz-^key1=value1-zz-key2=value2'] }
    end
  end

  context "with startup_script" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:startup_script => '../examples/gce_instance/example-startup-script.sh'} }
      let(:gcloud_additional_params) { ['--metadata-from-file', "startup-script=#{startup_script_file}"] }
    end
  end

  context "with puppet_master" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:puppet_master => 'master-blaster'} }
      let(:gcloud_additional_params) { ['--metadata', '^-zz-^puppet_master=master-blaster'] }
    end
  end

  context "with puppet_service" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:puppet_service => 'present'} }
      let(:gcloud_additional_params) { ['--metadata', '^-zz-^puppet_service=present'] }
    end
  end

  context "with puppet_manifest" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:puppet_manifest => "# install apache2 package and serve a page
class examples ($version = 'latest') {
  package {'apache2':
    ensure => $version, # Using the class parameter from above
  }
  file {'/var/www/index.html':
    ensure  => present,
    content => 'Pinocchio says hello!',
    require => Package['apache2'],
  }
  service {'apache2':
    ensure  => running,
    enable  => true,
    require => File['/var/www/index.html'],
  }
}
include examples
"} }
      let(:gcloud_additional_params) { ['--metadata', "^-zz-^puppet_manifest=#{puppet_manifest}"] }
    end
  end

  context "with puppet_modules" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:puppet_modules => ['puppetlabs-gce_compute','puppetlabs-mysql']} }
      let(:gcloud_additional_params) { ['--metadata', "^-zz-^puppet_modules=puppetlabs-gce_compute puppetlabs-mysql"] }
    end
  end

  context "with puppet_module_repos" do
    it_behaves_like "a resource that can be created" do
      let(:additional_params) { {:puppet_module_repos => {'puppetlabs-gce_compute' => 'git://github.com/puppetlabs/puppetlabs-gce_compute',
                                                          'puppetlabs-mysql' => 'git://github.com/puppetlabs/puppetlabs-mysql'}} }
      let(:gcloud_additional_params) { ['--metadata', "^-zz-^puppet_module_repos=git://github.com/puppetlabs/puppetlabs-gce_compute#puppetlabs-gce_compute git://github.com/puppetlabs/puppetlabs-mysql#puppetlabs-mysql"] }
    end
  end

  context "with block_for_startup_script" do
    let(:ssh_params) { ['compute', 'ssh', 'name', '--zone', 'us-central1-f', '--command', 'tail /var/log/startupscript.log -n 1'] }
    let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                          :zone => 'us-central1-f',
                                                          :startup_script => '../examples/gce_instance/example-startup-script.sh',
                                                          :block_for_startup_script => true) }

    describe "create" do
      it "should return nil when a resource is created" do
        expect(provider).to receive(:gcloud).with(*gcloud_base_params + ['--metadata-from-file', "startup-script=#{startup_script_file}"])
        expect(provider).to receive(:gcloud).with(*ssh_params).exactly(3).times.and_return('Not done', 'Still not done', 'Finished running startup script')
        expect(provider).to receive(:sleep).exactly(2).times.and_return(nil)
        expect(provider.create).to be_nil
      end
    end

    context "and with a startup_script_timeout" do
      let(:resource) { Puppet::Type.type(:gce_instance).new(:name => 'name',
                                                            :zone => 'us-central1-f',
                                                            :startup_script => '../examples/gce_instance/example-startup-script.sh',
                                                            :block_for_startup_script => true,
                                                            :startup_script_timeout => 0.001) }
      describe "create" do
        it "should raise an error when a resource is created because the timeout is reached" do
          expect(provider).to receive(:gcloud).with(*gcloud_base_params + ['--metadata-from-file', "startup-script=#{startup_script_file}"])
          expect(provider).to receive(:gcloud).with(*ssh_params) { sleep 1 }
          expect { provider.create }.to raise_error(Puppet::Error)
        end
      end
    end
  end
end
