require 'puppet'
require 'spec_helper'

gce_network = Puppet::Type.type(:gce_network)

describe gce_network do

  let :params do
    [
     :name,
     :gateway,
     :range,
     :reserve
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_network.parameters.should be_include(param)
    end
  end
end
