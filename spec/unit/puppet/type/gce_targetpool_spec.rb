require 'spec_helper'

describe Puppet::Type.type(:gce_targetpool) do
  let(:params) { [:name,
                  :region,
                  :description,
                  :health_check,
                  :session_affinity,
                  :backup_pool,
                  :failover_ratio] }

  it "should have expected parameters" do
    expect(described_class.parameters).to match_array(params + [:provider])
  end

  it "should be invalid without a name" do
    expect { described_class.new({}) }.to raise_error(/Title or name/)
  end

  it "should be invalid with an invalid name" do
    expect { described_class.new({:name => 'invalid-name-'}) }.to raise_error(/Invalid name/)
  end

  it "should be invalid with backup_pool and no failover_ratio" do
    expect { described_class.new({:name => 'name', :backup_pool => 'backup-pool'}) }.to raise_error(/Either both or neither of backup_pool and failover_ratio/)
  end

  it "should be invalid with no backup_pool and a failover_ratio" do
    expect { described_class.new({:name => 'name', :failover_ratio => 0.5}) }.to raise_error(/Either both or neither of backup_pool and failover_ratio/)
  end
end
