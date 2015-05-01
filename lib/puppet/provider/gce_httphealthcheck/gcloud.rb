Puppet::Type.type(:gce_httphealthcheck).provide(:gcloud) do
  commands :gcloud => "gcloud"

  def gcloud_args
    {:check_interval_sec => '--check-interval',
     :check_timeout_sec => '--timeout',
     :description => '--description',
     :healthy_threshold => '--healthy-threshold',
     :host => '--host',
     :port => '--port',
     :request_path => '--request-path',
     :unhealthy_threshold => '--unhealthy-threshold'}
  end

  def exists?
    begin
      gcloud('compute', 'http-health-checks', 'describe', resource[:name])
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    args = ["compute", "http-health-checks", "create", resource[:name]]
    gcloud_args.each do |symbol, arg|
      if resource[symbol]
        args << arg
        args << resource[symbol]
      end
    end
    gcloud(*args)
  end

  def destroy
    args = ["compute", "http-health-checks", "delete", resource[:name]]
    gcloud(*args)
  end
end
