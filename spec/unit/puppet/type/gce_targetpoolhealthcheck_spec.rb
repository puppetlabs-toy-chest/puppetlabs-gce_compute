require 'spec_helper'

gce_targetpoolhealthcheck = Puppet::Type.type(:gce_targetpoolhealthcheck)

describe gce_targetpoolhealthcheck do

  let :params do
    [
     :name,
     :health_check,
     :region,
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_targetpoolhealthcheck.parameters.should be_include(param)
    end
  end
end
