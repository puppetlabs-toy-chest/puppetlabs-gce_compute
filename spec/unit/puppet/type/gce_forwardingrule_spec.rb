require 'puppet'
require 'spec_helper'

gce_forwardingrule = Puppet::Type.type(:gce_forwardingrule)

describe gce_forwardingrule do

  let :params do
    [
     :name,
     :description,
     :ip,
     :port_range,
     :protocol,
     :region,
     :target,
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_forwardingrule.parameters.should be_include(param)
    end
  end
end
