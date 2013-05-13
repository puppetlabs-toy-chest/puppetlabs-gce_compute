require 'puppet'
require 'spec_helper'

gce_instance = Puppet::Type.type(:gce_instance)

describe gce_instance do

  let :params do
    [
     :name,
     :authorized_ssh_keys,
     :description,
     :disk,
     :zone,
     :tags,
     :use_compute_key,
     :tags,
     :network,
     :image,
     :machine_type,
     #property :metadata,
     #property :wait_until_running,
     #property :external_ip_address,
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_instance.parameters.should be_include(param)
    end
  end
end
