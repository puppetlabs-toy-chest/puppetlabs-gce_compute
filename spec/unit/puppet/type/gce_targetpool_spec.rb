require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_targetpool) do
  let(:params) { [:name,
                  :region,
                  :description,
                  :health_check,
                  :instances,
                  :session_affinity,
                  :backup_pool,
                  :failover_ratio] }
  let(:create_params) { {:name => 'name'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"

  it "should be invalid without a region" do
    expect { described_class.new({:name => 'name'}) }.to raise_error(/region/)
  end

  it "should be invalid with backup_pool and no failover_ratio" do
    expect { described_class.new({:name => 'name', :region => 'region', :backup_pool => 'backup-pool'}) }.to raise_error(/Either both or neither of backup_pool and failover_ratio/)
  end

  it "should be invalid with no backup_pool and a failover_ratio" do
    expect { described_class.new({:name => 'name', :region => 'region', :failover_ratio => 0.5}) }.to raise_error(/Either both or neither of backup_pool and failover_ratio/)
  end
end
