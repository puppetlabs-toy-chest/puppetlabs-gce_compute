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
      gcloud(*build_gcloud_args('describe'))
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    gcloud(*build_gcloud_create_args)
  end

  def destroy
    gcloud(*build_gcloud_args('delete'))
  end

  def build_gcloud_create_args
    build_gcloud_args('create') + build_gcloud_optional_create_args
  end

  def build_gcloud_args(action)
    ['compute', gcloud_resource_name, action, resource[:name]] + gcloud_args
  end

  def build_gcloud_optional_create_args
    args = []
    gcloud_optional_create_args.each do |attribute, flag|
      if resource[attribute]
        args << flag
        args << resource[attribute]
      end
    end
    return args
  end
end
