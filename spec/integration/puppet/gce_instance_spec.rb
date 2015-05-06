require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_instance" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type) { Puppet::Type.type(:gce_instance) }
    let(:describe_args) { 'puppet-test-instance --zone us-central1-a' }
    let(:expected_properties) { {'name'        => 'puppet-test-instance',
                                 'zone'        => /us-central1-a/,
                                 'description' => "Instance for testing the puppetlabs-gce_compute module",
                                 'machineType' => /f1-micro/,
                                 'machineType' => /f1-micro/,
                                 'canIpForward' => true} }
    let(:other_property_expectations) do
      Proc.new do |out|
        expect(out['networkInterfaces'].size).to eq(1)
        expect(out['networkInterfaces'][0]['network']).to match(/puppet-test-instance-network/)
        expect(out['scheduling']['onHostMaintenance']).to match('TERMINATE')
        expect(out['tags']['items']).to match_array(['tag1', 'tag2'])
        expect(out['metadata']['items'].size).to eq(1)
        expect(out['metadata']['items']).to include({'key'   => 'test-metadata-key',
                                                     'value' => 'test-metadata-value'})

        disk_out = IntegrationSpecHelper.describe_out('disks', 'puppet-test-instance --zone us-central1-a')
        expect(disk_out['sourceImage']).to match(/coreos/)

        instance_from_disk_out = IntegrationSpecHelper.describe_out('instances', 'puppet-test-instance-from-disk --zone us-central1-a')
        expect(instance_from_disk_out['disks'].size).to eq(1)
        expect(instance_from_disk_out['disks'][0]['source']).to match(/puppet-test-instance-from-disk-disk/)
      end
    end
  end
end
