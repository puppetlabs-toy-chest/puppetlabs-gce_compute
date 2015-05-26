require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))
require 'json'

Puppet::Type.type(:gce_forwardingrule).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  confine :gcloud_compatible_version => true
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'forwarding-rules'
  end

  # These arguments are required for both create and destroy
  def gcloud_args
    {:region => '--region'}
  end

  def gcloud_optional_create_args
    {:description => '--description',
     :ip_protocol => '--ip-protocol',
     :port_range  => '--port-range',
     :target_pool => '--target-pool'}
  end

  def create
    args = build_gcloud_args('create') + build_gcloud_flags(gcloud_optional_create_args)
    append_address_args(args, resource)
    gcloud(*args)
  end

  def append_address_args(args, resource)
    # NOTE gcloud should handle address the same way that it handles address for instance, but doesn't:
    # you must pass in the numeric IP address, not the name of the address resource.  This works around
    # that by querying for the address resource, and pulling the numeric IP address from the output.
    if resource[:address]
      address_describe = gcloud('compute', 'addresses', 'describe', resource[:address], '--region', resource[:region], '--format', 'json')
      args << '--address'
      args << JSON.parse(address_describe)['address']
    end
  end
end
