class Puppet::Provider::Gcloud < Puppet::Provider
  # These arguments are required for both create and destroy
  def gcloud_args
    {}
  end

  def gcloud_optional_create_args
    {}
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
    gcloud(*(build_gcloud_args('create') + build_gcloud_flags(gcloud_optional_create_args)))
  end

  def destroy
    gcloud(*build_gcloud_args('delete'))
  end

  def build_gcloud_args(action)
    ['compute', gcloud_resource_name, action, resource[:name]] + build_gcloud_flags(gcloud_args)
  end

  def build_gcloud_flags(args_hash)
    args = []
    args_hash.each do |attribute, flag|
      if resource[attribute]
        args << flag
        if resource[attribute].is_a? Array
          args << resource[attribute].join(',')
        else
          args << resource[attribute]
        end
      end
    end
    return args
  end
end
