require 'puppet'
require 'spec_helper'

gce_httphealthcheck = Puppet::Type.type(:gce_httphealthcheck)

describe gce_httphealthcheck do

  let :params do
    [
     :name,
     :description,
     :check_interval_sec,
     :check_timeout_sec,
     :healthy_threshold,
     :host,
     :port,
     :request_path,
     :unhealthy_threshold,
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_httphealthcheck.parameters.should be_include(param)
    end
  end
end
