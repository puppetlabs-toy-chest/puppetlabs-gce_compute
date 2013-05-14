require 'puppet'
require 'spec_helper'

gce_firewall = Puppet::Type.type(:gce_firewall)

describe gce_firewall do

  let :params do
    [
     :name,
     :description,
     :network,
     :allowed,
     :allowed_ip_sources,
     :allowed_tag_sources,
     :target_tags
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_firewall.parameters.should be_include(param)
    end
  end
end
