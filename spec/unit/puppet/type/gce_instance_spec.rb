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
     :persistent_boot_disk,
     :can_ip_forward,
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_instance.parameters.should be_include(param)
    end
  end
end
