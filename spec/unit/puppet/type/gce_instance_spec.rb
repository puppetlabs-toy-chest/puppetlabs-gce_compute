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
     :network,
     :image,
     :machine_type,
     :on_host_maintenance,
     :puppet_master,
     :puppet_service,
     :can_ip_forward,
     :add_compute_key_to_project,
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_instance.parameters.should be_include(param)
    end
  end
end
