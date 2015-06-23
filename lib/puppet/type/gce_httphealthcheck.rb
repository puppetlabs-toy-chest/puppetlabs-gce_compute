require 'puppet_x/puppetlabs/name_validator'

Puppet::Type.newtype(:gce_httphealthcheck) do
  desc 'Google Compute Engine HTTP health check for load balanced instances'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the disk.'
    validate do |v|
      PuppetX::Puppetlabs::NameValidator.validate(v)
    end
  end

  newparam(:description) do
    desc 'An optional, textual description for the HTTP health check.'
  end

  newparam(:check_interval) do
    desc 'How often to perform a health check for an instance.'
  end

  newparam(:timeout) do
    desc "If Google Compute Engine doesn't receive an HTTP 200 response from the instance by the time specified by the value of this flag, the health check request is considered a failure."
  end

  newparam(:healthy_threshold) do
    desc 'The number of consecutive successful health checks before an unhealthy instance is marked as healthy.'
  end

  newparam(:host) do
    desc 'The value of the host header used in this HTTP health check request.'
  end

  newparam(:port) do
    desc 'The TCP port number that this health check monitors.'
  end

  newparam(:request_path) do
    desc 'The request path that this health check monitors.'
  end

  newparam(:unhealthy_threshold) do
    desc 'The number of consecutive health check failures before a healthy instance is marked as unhealthy.'
  end
end
