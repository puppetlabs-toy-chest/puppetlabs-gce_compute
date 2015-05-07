require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_firewallrule" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type_name) { 'gce_firewallrule' }
    let(:gcloud_resource_name) { 'firewall-rules' }
    let(:describe_args) { 'puppet-test-firewall-rule' }
    let(:expected_properties) { {'name'        => 'puppet-test-firewall-rule',
                                 'description' => "Firewall rule for testing the puppetlabs-gce_compute module",
                                 'allowed' => [ { "IPProtocol" => "tcp", "ports" => [ "1-66" ] }, { "IPProtocol" => "udp", "ports" => [ "1-666" ] } ],
                                 'network' => /puppet-test-firewall-rule-network/,
                                 'sourceRanges' => ["192.168.0.0",  "192.168.100.0/24"],
                                 'sourceTags' => ["my-allowed-tag1", "my-allowed-tag2"],
                                 'targetTags' => ["my-target-tag1", "my-target-tag2"]} }
  end
end
