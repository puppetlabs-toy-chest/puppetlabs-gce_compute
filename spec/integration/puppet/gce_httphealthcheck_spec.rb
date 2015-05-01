require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_httphealthcheck" do
  it "runs creates and destroys a httphealthcheck" do
    expect(IntegrationSpecHelper.describe_err('http-health-checks', 'puppet-test-http-health-check')).to match(/ERROR: .* Could not fetch resource/)

    IntegrationSpecHelper.apply_example('gce_httphealthcheck/up_httphealthcheck')
    out = IntegrationSpecHelper.describe_out('http-health-checks', 'puppet-test-http-health-check')
    expect(out['checkIntervalSec']).to eq(7)
    expect(out['timeoutSec']).to eq(7)
    expect(out['description']).to eq("Http-health-check for testing the puppetlabs-gce_compute module")
    expect(out['healthyThreshold']).to eq(7)
    expect(out['host']).to eq('testhost')
    expect(out['port']).to eq(666)
    expect(out['requestPath']).to eq('/test/path')
    expect(out['unhealthyThreshold']).to eq(7)

    IntegrationSpecHelper.apply_example('gce_httphealthcheck/down_httphealthcheck')
    expect(IntegrationSpecHelper.describe_err('http-health-checks', 'puppet-test-http-health-check')).to match(/ERROR: .* Could not fetch resource/)
  end

  it "complains about an invalid httphealthcheck" do
    _, err = IntegrationSpecHelper.apply_example('gce_httphealthcheck/bad_httphealthcheck')
    expect(err).to match(/failed/)
  end
end
