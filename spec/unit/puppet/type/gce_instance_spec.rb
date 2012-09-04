require 'puppet'

gce_instance = Puppet::Type.type(:gce_instance)

describe gce_instance do

  let :params do
    [
     :name,
     :authorized_ssh_keys,
     :description,
     :disk,
     :external_ip_address,
     :zone,
     :tags,
     :wait_until_running,
     :use_compute_key,
     :metadata,
     :tags,
     :network,
     :image,
     :machine
    ]
  end

  it "should have expected parameters" do
    params.each do |param|
      gce_instance.parameters.should be_include(param)
    end
  end
end
