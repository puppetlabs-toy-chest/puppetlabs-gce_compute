require 'puppet'
require 'spec_helper'

gce_targetpool = Puppet::Type.type(:gce_targetpool)

describe gce_targetpool do

  let :params do
    [
     :name,
     :description,
     :health_checks,
     :instances,
     :region,
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_targetpool.parameters.should be_include(param)
    end
  end
end
