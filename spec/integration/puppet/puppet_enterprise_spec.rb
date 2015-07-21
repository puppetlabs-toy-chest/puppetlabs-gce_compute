require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "puppet-enterprise.sh" do
  let(:gcloud_resource_name) { 'instances' }

  it "configures Puppet correctly" do
    expect(IntegrationSpecHelper.describe_err(gcloud_resource_name, 'puppet-test-enterprise-master-instance --zone us-central1-f')).to match(/ERROR: .* Could not fetch resource/)

    IntegrationSpecHelper.apply_example("puppet_enterprise/up")

    ps_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-enterprise-master-instance --zone us-central1-f --command "ps ax"')

    # TODO expect Puppet Enterprise to be running properly

    # expect puppet_modules
    modules_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-enterprise-master-instance --zone us-central1-f --command "sudo puppet module list"')
    expect(modules_out).to match(/puppetlabs-apache/)
    expect(modules_out).to match(/puppetlabs-stdlib/)
    expect(modules_out).to match(/puppetlabs-concat/)

    # expect puppet_module_repos
    expect(modules_out).to match(/puppetlabs-gce_compute/)
    ls_gce_compute_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-enterprise-master-instance --zone us-central1-f --command "sudo cat /etc/puppetlabs/puppet/modules/puppetlabs-gce_compute/.git/config"')
    expect(ls_gce_compute_out).to match(/url = git:\/\/github.com\/puppetlabs\/puppetlabs-gce_compute/)

    expect(modules_out).to match(/puppetlabs-mysql/)
    ls_gce_compute_out, _ = IntegrationSpecHelper.run_command('gcloud compute ssh puppet-test-enterprise-master-instance --zone us-central1-f --command "sudo cat /etc/puppetlabs/puppet/modules/puppetlabs-mysql/.git/config"')
    expect(ls_gce_compute_out).to match(/url = git:\/\/github.com\/puppetlabs\/puppetlabs-mysql/)

    IntegrationSpecHelper.apply_example("puppet_enterprise/down")
    expect(IntegrationSpecHelper.describe_err(gcloud_resource_name, 'puppet-test-enterprise-master-instance --zone us-central1-f')).to match(/ERROR: .* Could not fetch resource/)
  end
end
