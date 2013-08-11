require 'puppet'
require 'spec_helper'

gce_targetpoolinstance = Puppet::Type.type(:gce_targetpoolinstance)

describe gce_targetpoolinstance do

  let :params do
    [
     :name,
     :instance,
     :region,
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_targetpoolinstance.parameters.should be_include(param)
    end
  end
end
