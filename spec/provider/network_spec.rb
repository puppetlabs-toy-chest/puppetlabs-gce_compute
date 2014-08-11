require 'spec_helper'

provider_class = Puppet::Type.type(:gce_network).provider(:fog)

describe provider_class do

  context '#init_create' do
    let(:provider) { provider_class.new(
      :name => 'test-nework',
    )}

    it 'correctly returns ipv4_range' do
      provider.resource = {:range => '10.250.0.0/16'}
      expect(provider.init_create).to eq({:ipv4_range => '10.250.0.0/16'})
    end

    it 'correctly returns gateway_ipv4' do
      provider.resource = {:range => '10.250.0.0/16', :gateway => '10.250.0.1'}
      expect(provider.init_create).to eq({:ipv4_range => '10.250.0.0/16',
                                         :gateway_ipv4 => '10.250.0.1'})
    end
  end

end
