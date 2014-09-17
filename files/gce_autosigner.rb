#!/opt/puppet/bin/ruby
require 'etc'
ENV['HOME'] = Etc.getpwuid(Process.uid).dir

require 'json'
require 'open-uri'
require 'puppet'
require 'puppet/ssl/certificate_request'

# Obtain information from the nodes certificate request
csr = Puppet::SSL::CertificateRequest.from_s(STDIN.read)
csr_instance_id = csr.custom_attributes.find { |a| a['oid'] == 'pp_instance_id' }['value']
csr_instance_name = csr.custom_attributes.find { |a| a['oid'] == '1.3.6.1.4.1.34380.1.2.1' }['value']
csr_uuid = csr.request_extensions.find { |a| a['oid'] == 'pp_uuid' }['value']

# Get authoritative information from GCE API
get_token = open("http://metadata/computeMetadata/v1/instance/service-accounts/default/token",
    "X-Google-Metadata-Request" => "TRUE",
)
token = JSON.parse(get_token.string)['access_token']

query_instance = open("https://www.googleapis.com/compute/v1/#{csr_instance_id}/instances/#{csr_instance_name}",
    "X-Google-Metadata-Request" => "TRUE",
    "Authorization" => "Bearer #{token}"
)
metadata_uuid = JSON.parse(query_instance.read)['id']

# Cert is safe to sign (retcode=0) if the id from metadata
# is the same as what the agent sent in its csr
if metadata_uuid == csr_uuid
  retcode = 0
elsif
  retcode = 1
end
exit retcode
