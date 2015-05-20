require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_forwardingrule" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type_name) { 'gce_forwardingrule' }
    let(:gcloud_resource_name) { 'forwarding-rules' }
    let(:describe_args) { 'puppet-test-forwarding-rule --region us-central1' }
    let(:address) { IntegrationSpecHelper.describe_out('addresses', 'puppet-test-forwarding-rule-address --region us-central1')['address'] }
    let(:expected_properties) { {'name'        => 'puppet-test-forwarding-rule',
                                 'region'      => /us-central1/,
                                 'IPAddress'   => address,
                                 'IPProtocol'  => 'UDP',
                                 'portRange'   => '1-66',
                                 'target'      => /puppet-test-forwarding-rule-target-pool/,
                                 'description' => "Forwarding rule for testing the puppetlabs-gce_compute module"} }
  end
end
