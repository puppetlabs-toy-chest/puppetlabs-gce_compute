require 'puppet/parameter/boolean'

Puppet::Type.newtype(:gce_httphealthcheck) do
  desc 'httphealthcheck'

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /^[a-z][-a-z0-9]{0,61}[a-z0-9]\Z/
        raise(Puppet::Error, "Invalid httphealthcheck name: #{value}")
      end
    end
  end

  newparam(:check_interval_sec) do
    desc 'How often in seconds to send a health check'
    validate do |value|
      unless value.is_a? Integer and value > 0
        raise "Check interval needs to be integer seconds greater than zero #{value}"
      end
    end
  end

  newparam(:check_timeout_sec) do
    desc 'How long to wait on a check before declaring failure'
    validate do |value|
      unless value.is_a? Integer and value > 0
        raise "Check timeout needs to be integer seconds greater than zero #{value}"
      end
    end
  end

  newparam(:description) do
    desc 'forwardingrule description'
  end

  newparam(:healthy_threshold) do
    desc 'A so-far unhealthy instance will be marked healthy after this many postivie checks'
    validate do |value|
      unless value.is_a? Integer and value > 0
        raise "Healthy threshold must an integer greather than zero #{value}"
      end
    end
  end

  newparam(:host) do
    desc 'The hostname of the instance to check'
  end

  newparam(:port) do
    desc 'The port to use for HTTP health check requests'
    validate do |value|
      unless value.is_a? Integer and value > 0
        raise "The port must be an integer greater than zero #{value}"
      end
    end
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
    validate do |value|
      unless value.is_a? Integer and value > 0
        raise "Unhealthy threshold must an integer greather than zero #{value}"
      end
    end
  end

  newparam(:async_create, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'wait until health check is ready when creating'
    defaultto :false
  end

  newparam(:async_destroy, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'wait until health check is deleted'
    defaultto :false
  end

  autorequire(:gce_auth) do
    requires = []
    catalog.resources.each {|rsrc|
      requires << rsrc.name if rsrc.class.to_s == 'Puppet::Type::Gce_auth'
    }
    requires
  end

end
