class Puppet::Provider::Gcloud < Puppet::Provider
  # These arguments are required for both create and destroy
  def gcloud_args
    []
  end

  def exists?
    begin
      args = ['compute', gcloud_resource_arg, 'describe', resource[:name]] + gcloud_args
      gcloud(*args)
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    args = ['compute', gcloud_resource_arg, 'create', resource[:name]] + gcloud_args
    gcloud_optional_args.each do |symbol, arg|
      if resource[symbol]
        args << arg
        args << resource[symbol]
      end
    end
    gcloud(*args)
  end

  def destroy
    args = ['compute', gcloud_resource_arg, 'delete', resource[:name]] + gcloud_args
    gcloud(*args)
  end
end
