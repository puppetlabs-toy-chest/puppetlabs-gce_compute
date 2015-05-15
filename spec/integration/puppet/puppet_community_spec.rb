require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "puppet-community.sh" do
  let(:gcloud_resource_name) { 'instances' }

  it "configures Puppet correctly" do
    expect(IntegrationSpecHelper.describe_err(gcloud_resource_name, 'puppet-test-community-instance --zone us-central1-a')).to match(/ERROR: .* Could not fetch resource/)

    IntegrationSpecHelper.apply_example("puppet_community/up")

    # expect puppet_modules
    modules_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-community-instance --zone us-central1-a --command "sudo puppet module list"')
    expect(modules_out).to match(/puppetlabs-mysql/)
    expect(modules_out).to match(/puppetlabs-apache/)
    expect(modules_out).to match(/puppetlabs-stdlib/)
    expect(modules_out).to match(/puppetlabs-concat/)

    IntegrationSpecHelper.apply_example("puppet_community/down")
    expect(IntegrationSpecHelper.describe_err(gcloud_resource_name, 'puppet-test-community-instance --zone us-central1-a')).to match(/ERROR: .* Could not fetch resource/)
  end
end
