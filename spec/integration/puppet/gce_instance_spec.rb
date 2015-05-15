require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_instance" do
  let(:type_name) { 'gce_instance' }
  let(:gcloud_resource_name) { 'instances' }

  it_behaves_like "a resource that can be created and destroyed" do
    let(:describe_args) { 'puppet-test-instance --zone us-central1-a' }
    let(:expected_properties) { {'name'        => 'puppet-test-instance',
                                 'zone'        => /us-central1-a/,
                                 'description' => "Instance for testing the puppetlabs-gce_compute module",
                                 'machineType' => /f1-micro/,
                                 'canIpForward' => true} }

    let(:other_property_expectations) do
      Proc.new do |out|
        # expect network
        expect(out['networkInterfaces'].size).to eq(1)
        expect(out['networkInterfaces'][0]['network']).to match(/puppet-test-instance-network/)

        # expect address
        address_out = IntegrationSpecHelper.describe_out('addresses', 'puppet-test-instance-address --region us-central1')
        expect(out['networkInterfaces'][0]['accessConfigs'].size).to eq(1)
        expect(out['networkInterfaces'][0]['accessConfigs'][0]['natIP']).to eq(address_out['address'])

        # expect maintenance_policy
        expect(out['scheduling']['onHostMaintenance']).to match('TERMINATE')

        # expect tags
        expect(out['tags']['items']).to match_array(['tag1', 'tag2'])

        # expect metadata
        expect(out['metadata']['items']).to include({'key'   => 'test-metadata-key',
                                                     'value' => 'test-metadata-value'})

        # expect scopes
        expect(out['serviceAccounts'].size).to eq(1)
        expect(out['serviceAccounts'][0]['scopes'].size).to eq(2)
        expect(out['serviceAccounts'][0]['scopes']).to match_array(['https://www.googleapis.com/auth/compute',
                                                                    'https://www.googleapis.com/auth/devstorage.read_write'])

        # expect startup_script
        startup_script_metadata = out['metadata']['items'].select { |item| item['key'] == 'startup-script' }[0]
        expect(startup_script_metadata).not_to be_nil
        expect(startup_script_metadata['value']).to match(/an example startup script that does nothing/)

        # expect puppet stuff
        expect(out['metadata']['items']).to include({'key'   => 'puppet_master',
                                                     'value' => 'master-blaster'})
        expect(out['metadata']['items']).to include({'key'   => 'puppet_service',
                                                     'value' => 'present'})
        expect(out['metadata']['items']).to include({'key'   => 'puppet_manifest',
                                                     'value' => <<-PUPPET_MANIFEST
class apache ($version = "latest") {
  package {"apache2":
    ensure => $version, # Using the class parameter from above
  }
  file {"/var/www/index.html":
    ensure  => present,
    content => "<html>\\n<body>\\n\\t<h2>Hi, this is $gce_external_ip.</h2>\\n</body>\\n</html>\\n",
    require => Package["apache2"],
  }
  service {"apache2":
    ensure => running,
    enable => true,
    require => File["/var/www/index.html"],
  }
}
include apache
PUPPET_MANIFEST
          })
        expect(out['metadata']['items']).to include({'key'   => 'puppet_modules',
                                                     'value' => 'puppetlabs-gce_compute puppetlabs-mysql'})
        expect(out['metadata']['items']).to include({'key'   => 'puppet_module_repos',
                                                     'value' => 'git://github.com/puppetlabs/puppetlabs-gce_compute#puppetlabs-gce_compute git://github.com/puppetlabs/puppetlabs-mysql#puppetlabs-mysql'})

        # expect image
        disk_out = IntegrationSpecHelper.describe_out('disks', 'puppet-test-instance --zone us-central1-a')
        expect(disk_out['sourceImage']).to match(/coreos/)

        # expect disk
        instance_alt_out = IntegrationSpecHelper.describe_out('instances', 'puppet-test-instance-alt --zone us-central1-a')
        expect(instance_alt_out['disks'].size).to eq(1)
        expect(instance_alt_out['disks'][0]['source']).to match(/puppet-test-instance-alt-disk/)
      end
    end
  end

  it "times out when creating a resource with a short timeout" do
    expect(IntegrationSpecHelper.describe_err(gcloud_resource_name, 'puppet-test-timeout-instance --zone us-central1-a')).to match(/ERROR: .* Could not fetch resource/)

    _, err = IntegrationSpecHelper.apply_example("#{type_name}/timeout_up")
    expect(err).to match(/Timed out/)

    IntegrationSpecHelper.apply_example("#{type_name}/timeout_down")
    expect(IntegrationSpecHelper.describe_err(gcloud_resource_name, 'puppet-test-timeout-instance --zone us-central1-a')).to match(/ERROR: .* Could not fetch resource/)
  end
end
