require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_forwardingrule" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type) { Puppet::Type.type(:gce_forwardingrule) }
    let(:describe_args) { 'puppet-test-forwarding-rule --region us-central1' }
    let(:expected_properties) { {'name'        => 'puppet-test-forwarding-rule',
                                 'region'      => /us-central1/,
                                 'IPProtocol'  => 'UDP',
                                 'portRange'   => '1-66',
                                 'target'      => /puppet-test-forwarding-rule-target-pool/,
                                 'description' => "Forwarding rule for testing the puppetlabs-gce_compute module"} }
  end
end
