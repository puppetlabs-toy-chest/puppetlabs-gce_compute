Puppet::Type.type(:gce_disk).provide(:gcloud) do
  commands :gcloud => "gcloud"

  def gcloud_args
    {:size_gb => '--size',
     :description => '--description',
     :source_image => '--image'}
   end

  def exists?
    begin
      gcloud('compute', 'disks', 'describe', resource[:name], '--zone', resource[:zone])
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    args = ["compute", "disks", "create", resource[:name], '--zone', resource[:zone]]
    gcloud_args.each do |symbol, arg|
      if resource[symbol]
        args << arg
        args << resource[symbol]
      end
    end
    gcloud(*args)
  end

  def destroy
    args = ["compute", "disks", "delete", resource[:name], '--zone', resource[:zone]]
    gcloud(*args)
  end

end
