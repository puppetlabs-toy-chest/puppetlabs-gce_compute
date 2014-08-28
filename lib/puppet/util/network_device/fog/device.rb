module Puppet::Util::NetworkDevice::Fog
  class Device

    attr_accessor :auth_file, :project_id

    # initialize gce device. The device should be of the form:
    # [auth_file]:project_id
    def initialize(url)
      if url =~ /\[(.*)?\]:(\S+)/
        @auth_file  = File.expand_path($1)
        @project_id = $2
        unless File.exists?(@auth_file)
          raise(Puppet::Error, "Auth file #{@auth_file} does not exist.\
            it should be created manually before the puppet run begins.")
        end
      else
        raise(Puppet::Error,
              "Invalid URL: #{url}. Should match [auth_file]:project_id")
      end
    end

    def facts
      {}
    end

  end
end
