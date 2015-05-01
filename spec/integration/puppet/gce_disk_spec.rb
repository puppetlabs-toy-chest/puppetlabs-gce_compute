require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_disk" do
  it "runs creates and destroys a disk" do
    expect(IntegrationSpecHelper.describe_err('disks', 'puppet-test-disk --zone us-central1-a')).to match(/ERROR: .* Could not fetch resource/)

    IntegrationSpecHelper.apply_example('gce_disk/up_disk')
    out = IntegrationSpecHelper.describe_out('disks', 'puppet-test-disk --zone us-central1-a')
    expect(out['name']).to eq('puppet-test-disk')
    expect(out['zone']).to match(/us-central1-a/)
    expect(out['sizeGb']).to eq('11')
    expect(out['description']).to eq("Disk for testing the puppetlabs-gce_compute module")
    expect(out['sourceImage']).to match(/coreos/)

    IntegrationSpecHelper.apply_example('gce_disk/down_disk')
    expect(IntegrationSpecHelper.describe_err('disks', 'puppet-test-disk --zone us-central1-a')).to match(/ERROR: .* Could not fetch resource/)
  end

  it "complains about an invalid disk" do
    _, err = IntegrationSpecHelper.apply_example('gce_disk/bad_disk')
    expect(err).to match(/failed/)
  end
end
