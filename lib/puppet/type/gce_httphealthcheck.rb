Puppet::Type.newtype(:gce_httphealthcheck) do
  desc 'httphealthcheck'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?/
        raise(Puppet::Error, "Invalid httphealthcheck name: #{v}")
      end
    end
  end

  newparam(:check_interval_sec) do
    desc 'How often in seconds to send a health check'
  end

  newparam(:check_timeout_sec) do
    desc 'How long to wait on a check before declaring failure'
  end

  newparam(:description) do
    desc 'forwardingrule description'
  end

  newparam(:healthy_threshold) do
    desc 'A so-far unhealthy instance will be marked healthy after this many postivie checks'
  end

  newparam(:host) do
    desc 'The hostname of the instance to check'
  end

  newparam(:port) do
    desc 'The port to use for HTTP health check requests'
  end

  newparam(:request_path) do
    desc 'The request path for the HTTP health check'
    validate do |value|
      unless value.is_a? String and value.start_with? "/"
        raise "Request path must start with '/' #{value}"
      end
    end
  end

  newparam(:unhealthy_threshold) do
    desc 'Number of times to fail a healthcheck before being marked as failed'
  end
end
