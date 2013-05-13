require 'puppet'
require 'puppet/util/network_device/gce/device'
require 'spec_helper'

describe 'when creating gce devices' do
  it 'should initialize devices with valid urls' do
    File.expects(:exists?).with(File.expand_path('~/.gcutil.file')).returns(true)
    url     = '[~/.gcutil.file]:puppetlabs:project'
    gce_dev = Puppet::Util::NetworkDevice::Gce::Device.new(url)
    gce_dev.auth_file.should  == File.expand_path('~/.gcutil.file')
    gce_dev.project_id.should == 'puppetlabs:project'
  end
  it 'should fail when the auth file does not exist' do
    File.expects(:exists?).with(File.expand_path('~/.gcutil.file')).returns(false)
    url     = '[~/.gcutil.file]:puppetlabs:project'
    expect do
      gce_dev = Puppet::Util::NetworkDevice::Gce::Device.new(url)
    end.to raise_error(Puppet::Error)

  end
  it 'should fail when devices do not have valid urls' do
    url     = '[~/.gcutil.file:puppetlabs:project'
    expect do
      gce_dev = Puppet::Util::NetworkDevice::Gce::Device.new(url)
    end.to raise_error(Puppet::Error)
  end
end
