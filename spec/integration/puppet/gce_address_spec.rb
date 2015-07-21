require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_address" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type_name) { 'gce_address' }
    let(:gcloud_resource_name) { 'addresses' }
    let(:describe_args) { 'puppet-test-address --region us-central1' }
    let(:expected_properties) { {'name'        => 'puppet-test-address',
                                 'region'      => /us-central1/,
                                 'description' => "Address for testing the puppetlabs-gce_compute module"} }
  end
end
