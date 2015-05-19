require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_targetpool" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type_name) { 'gce_targetpool' }
    let(:gcloud_resource_name) { 'target-pools' }
    let(:describe_args) { 'puppet-test-target-pool --region us-central1' }
    let(:expected_properties) { {'name'            => 'puppet-test-target-pool',
                                 'description'     => "Target pool for testing the puppetlabs-gce_compute module",
                                 'region'          => /us-central1/,
                                 'sessionAffinity' => 'CLIENT_IP',
                                 'backupPool'      => /puppet-test-target-pool-backup/,
                                 'failoverRatio'   => 0.5} }
    let(:other_property_expectations) do
      Proc.new do |out|
        expect(out['healthChecks'].size).to eq(1)
        expect(out['healthChecks'][0]).to match(/puppet-test-target-pool-http-health-check/)

        expect(out['instances'].size).to eq(1)
        expect(out['instances'][0]).to match(/puppet-test-target-pool-instance/)
      end
    end
  end
end
