require 'spec_helper'

provider_class = Puppet::Type.type(:gce_firewall).provider(:fog)

describe provider_class do

  context '#puppet_fog_mappings' do
    it 'returns the correct values' do
      expect(provider_class.puppet_fog_mappings(:allowed_ip_sources)).to eq \
        :source_ranges
      expect(provider_class.puppet_fog_mappings(:allowed_tag_sources)).to eq \
        :source_tags
    end
  end

  context '#init_create' do
    let(:provider) { provider_class.new(:name => 'test-firewall') }

    it 'will allow all sources if neither allowed_ip_sources nor' \
      ' allowed_tag_sources is given' do
      provider.resource = {:allowed => 'tcp'}
      provider.init_create
      expect(provider.resource[:allowed_ip_sources]).to eq '0.0.0.0/0'
    end

    it 'raises error on unknown port string' do
      provider.resource = {:allowed => 'udp:bleh'}
      expect {provider.init_create}.to raise_error(Puppet::Error,
                                                   /no such service bleh/)
    end

    it 'will allow all ports if no port is given' do
      provider.resource = {:allowed => 'tcp',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp'}]
    end

    it 'will allow all ports for a protocol even if specific ports for ' \
      'that protocol are later specified separately' do
      provider.resource = {:allowed => 'tcp, tcp:22',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp'}]
    end

    it 'will allow all ports for a protocol even if specific ports for that ' \
      'protocol are specified earlier' do
      provider.resource = {:allowed => 'tcp:22, tcp',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp'}]
    end

    it 'will ignore repeated port numbers for the same protocol' do
      provider.resource = {:allowed => 'tcp:22, tcp:22',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp',
                                                 :ports => ['22']}]
    end

    it 'will ignore repeated port numbers for the same protocol even if one ' \
      'is a string' do
      provider.resource = {:allowed => 'tcp:22, tcp:ssh',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp',
                                                 :ports => ['22']}]
    end

    it 'will ignore repeated port numbers for the same protocol when they ' \
      'are both strings' do
      provider.resource = {:allowed => 'tcp:ssh, tcp:ssh',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp',
                                                 :ports => ['22']}]
    end


    # Note that this does not cover the case where the protocol is listed as
    # a string in one instance and a number in a second instance. In the case
    # just mentioned, 2 separate rules will be generated with the current code.
    # Fixing this requires either digging through some strange defines or use
    # a third party gem to look them up.
    it 'will combine ports for the same protocol into one rule' do
      provider.resource = {:allowed => 'tcp:22, tcp:80',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp',
                                                 :ports => ['22', '80']}]
    end

    it 'allows port ranges' do
      provider.resource = {:allowed => 'tcp:22-80',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp',
                                                 :ports => ['22-80']}]
    end


    it 'allows port ranges when the ports are mixed strings and numbers' do
      provider.resource = {:allowed => 'tcp:ssh-80',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp',
                                                 :ports => ['22-80']}]
    end

    it 'allows port ranges when the ports are strings' do
      provider.resource = {:allowed => 'tcp:ssh-http',
        :allowed_ip_sources => '0.0.0.0/0'}
      provider.init_create
      expect(provider.resource[:allowed]).to eq [{:IPProtocol => 'tcp',
                                                 :ports => ['22-80']}]
    end

    it 'returns a hash with source_ranges and source_tags' do
      provider.resource = {:allowed => 'tcp'}
      expect(provider.init_create).to eq({:source_ranges => ['0.0.0.0/0']})
    end

    it 'strips whitespace from source_ranges lists' do
      provider.resource = {:allowed => 'udp',
        :allowed_ip_sources => '0.0.0.0/0, 10.10.10.10/0'}
      expect(provider.init_create).to eq({:source_ranges => ['0.0.0.0/0',
                                         '10.10.10.10/0']})
    end

    it 'strips whitespace from source_tags lists' do
      provider.resource = {:allowed => 'udp',
        :allowed_tag_sources => 'puppet, puppet-master'}
      expect(provider.init_create).to eq({:source_tags => ['puppet',
                                         'puppet-master']})
    end

  end
end
