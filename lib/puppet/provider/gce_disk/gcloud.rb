require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_disk).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  confine :gcloud_compatible_version => true
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'disks'
  end

  # These arguments are required for both create and destroy
  def gcloud_args
    {:zone => '--zone'}
  end

  def gcloud_optional_create_args
    {:description => '--description',
     :size => '--size',
     :image => '--image'}
  end
end
