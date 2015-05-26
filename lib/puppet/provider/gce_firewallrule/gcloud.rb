require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_firewallrule).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  confine :gcloud_compatible_version => true
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'firewall-rules'
  end

  def gcloud_optional_create_args
    {:description => '--description',
     :allow => '--allow',
     :network => '--network',
     :source_ranges => '--source-ranges',
     :source_tags => '--source-tags',
     :target_tags => '--target-tags'}
  end
end
