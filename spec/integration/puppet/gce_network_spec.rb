require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_network" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type_name) { 'gce_network' }
    let(:gcloud_resource_name) { 'networks' }
    let(:describe_args) { 'puppet-test-network' }
    let(:expected_properties) { {'name'        => 'puppet-test-network',
                                 'description' => "Network for testing the puppetlabs-gce_compute module",
                                 'IPv4Range'   => "192.168.0.0/16"} }
  end
end
