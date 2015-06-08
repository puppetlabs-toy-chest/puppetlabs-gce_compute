require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_disk" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type_name) { 'gce_disk' }
    let(:gcloud_resource_name) { 'disks' }
    let(:describe_args) { 'puppet-test-disk --zone us-central1-f' }
    let(:expected_properties) { {'name'        => 'puppet-test-disk',
                                 'zone'        => /us-central1-f/,
                                 'description' => "Disk for testing the puppetlabs-gce_compute module",
                                 'sizeGb'      => '11',
                                 'sourceImage' => /coreos/} }
  end
end
