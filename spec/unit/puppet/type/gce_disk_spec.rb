require 'puppet'
require 'spec_helper'

gce_disk = Puppet::Type.type(:gce_disk)

describe gce_disk do

  let :params do
    [
     :name,
     :zone,
     :size_gb,
     :description
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_disk.parameters.should be_include(param)
    end
  end
end
