class Puppet::Provider::Gcloud < Puppet::Provider
  # These arguments are required for both create and destroy
  def gcloud_args
    []
  end

  def gcloud_optional_create_args
    []
  end

  def exists?
    begin
      args = ['compute', gcloud_resource_name, 'describe', resource[:name]] + gcloud_args
      gcloud(*args)
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    args = ['compute', gcloud_resource_name, 'create', resource[:name]] + gcloud_args
    gcloud_optional_create_args.each do |attribute, flag|
      if resource[attribute]
        args << flag
        args << resource[attribute]
      end
    end
    gcloud(*args)
  end

  def destroy
    args = ['compute', gcloud_resource_name, 'delete', resource[:name]] + gcloud_args
    gcloud(*args)
  end
end
