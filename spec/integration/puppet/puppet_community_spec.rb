require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "puppet-community.sh" do
  let(:gcloud_resource_name) { 'instances' }

  it "configures Puppet correctly" do
    expect(IntegrationSpecHelper.describe_err(gcloud_resource_name, 'puppet-test-community-instance --zone us-central1-a')).to match(/ERROR: .* Could not fetch resource/)

    IntegrationSpecHelper.apply_example("puppet_community/up")

    ps_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-community-instance --zone us-central1-a --command "ps ax"')

    # expect puppet_master
    config_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-community-instance --zone us-central1-a --command "sudo puppet config print"')
    expect(config_out).to match(/^server = master-blaster$/)

    # expect puppet_service
    rc_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-community-instance --zone us-central1-a --command "ls /etc/rc*.d -1"')
    expect(rc_out).to match(/puppet$/)
    expect(ps_out).to match(/puppet agent$/)

    # expect puppet_manifest
    index_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-community-instance --zone us-central1-a --command "cat /var/www/index.html"')
    expect(index_out).to match(/Pinocchio says hello!/)
    expect(ps_out).to match(/apache/)

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
