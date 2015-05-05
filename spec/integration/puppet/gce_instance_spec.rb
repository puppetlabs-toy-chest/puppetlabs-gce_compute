require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_instance" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type) { Puppet::Type.type(:gce_instance) }
    let(:describe_args) { 'puppet-test-instance --zone us-central1-a' }
    let(:expected_properties) { {'name'        => 'puppet-test-instance',
                                 'zone'        => /us-central1-a/,
                                 'description' => "Instance for testing the puppetlabs-gce_compute module"} }
  end
end
