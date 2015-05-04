require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_disk" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type) { 'gce_disk' }
    let(:provider) { Puppet::Type::Gce_disk::ProviderGcloud.new }
    let(:describe_args) { 'puppet-test-disk --zone us-central1-a' }
    let(:expected_properties) { {'name'        => 'puppet-test-disk',
                                 'zone'        => /us-central1-a/,
                                 'sizeGb'      => '11',
                                 'description' => "Disk for testing the puppetlabs-gce_compute module",
                                 'sourceImage' => /coreos/} }
  end
end
