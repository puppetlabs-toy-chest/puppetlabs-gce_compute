require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gcloud'))

Puppet::Type.type(:gce_firewallrule).provide(:gcloud, :parent => Puppet::Provider::Gcloud) do
  commands :gcloud => "gcloud"

  def gcloud_resource_name
    'firewall-rules'
  end

  def gcloud_optional_create_args
    {:description => '--description',
     :allowed => '--allow',
     :network => '--network',
     :allowed_ip_sources => '--source-ranges',
     :allowed_tag_sources => '--source-tags',
     :target_tags => '--target-tags'}
  end
end
