require 'spec_helper'

provider_class = Puppet::Type.type(:gce_disk).provider(:fog)

describe provider_class do

  context 'getting non-deprecated images' do
    let(:deprecated_image_names) {
      ['debian-7-wheezy-v20140605',
        'debian-7-wheezy-v20140606',
        'backports-debian-7-wheezy-v20140605',
        'backports-debian-7-wheezy-v20140606',
        'centos-6-v20140605',
        'centos-6-v20140606',
        'rhel-6-v20140605',
        'rhel-6-v20140606',
        'sles-11-sp3-v20140306']
    }
    let(:good_image_names) {
      ['debian-7-wheezy-v20140619',
        'backports-debian-7-wheezy-v20140619',
        'centos-6-v20140619',
        'rhel-6-v20140619',
        'sles-11-sp3-v20140609']
    }

    it 'gets images from fog' do
      disk_images = deprecated_image_names.collect {|img|
        disk_img = double(img)
        expect(disk_img).to receive(:deprecated).once.and_return('deprecated')
        disk_img
      }
      disk_images.concat good_image_names.collect {|img|
        disk_img = double(img)
        disk_img.stub(:name).and_return(img)
        expect(disk_img).to receive(:deprecated).once.and_return(nil)
        disk_img
      }
      images = stub('images')
      fog = stub('fog')
      expect(fog).to receive(:images).and_return(images)
      expect(images).to receive(:all).and_return(disk_images)
      provider_class.superclass.class_variable_set(:@@connection, fog)
      provider_class.get_os_images
      x = 0
      expect(provider_class.os_images).to eq good_image_names
    end
  end
end
