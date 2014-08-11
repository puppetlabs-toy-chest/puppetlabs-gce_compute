require 'fog'
 
 

def fogcall(device_type, attr, action, con)
  device = {'fog_disk' => con.disks,
    'fog_instance' => con.servers,
    'fog_network' => con.networks
  }
  device[device_type].method(action).call(attr)
end

connection = Fog::Compute.new({
  :provider => 'google',
  :google_project => 'upbeat-airway-600',
  :google_client_email => '793012070718-d7hg25tf75lkl8kae21q1fp70qmi6tcb@developer.gserviceaccount.com',
  :google_key_location => '/home/ashmrtnz/690c8ebf2431e5020e6c1c3aed048c81a470645a-privatekey.p12',
})

#connection.firewalls.create({:name => 'test-firewall', :network => 'default', :allowed => [{:ports => ['80', '8080-8090']}, {:IPProtocol => '6', :ports => ['42']}], :source_ranges => ['0.0.0.0/0']})
#connection.networks.create({:name => 'my-private-network-2', :ipv4_range => '10.250.0.0/16', :gateway_ipv4 => '10.250.0.1'})
#proj = connection.projects.get('upbeat-airway-600')
flavors = connection.images.all
image = 'backports-debian-7-wheezy-v20140606'
puts image['^backports']
binding.pry
puts 'hi'
