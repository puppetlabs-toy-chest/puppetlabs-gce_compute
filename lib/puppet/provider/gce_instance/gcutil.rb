require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_instance).provide(
  :gce_util,
  :parent => Puppet::Provider::Gce
) do

  commands :gcutil => 'gcutil'

  def self.instances
    gce_devices.values.collect do |dev|
      parse_instances(gcutilcmd(dev, 'listinstances')).collect do |row|
puts row[1]
        new(:name => row[1], :auth_file => dev.auth_file, :project_id => dev.project_id)
      end
    end.flatten
  end

  def create
    # ensure that wait until running is set...
    args = [
      :zone,
      :machine_type,
      :image,
      :network,
      :tags,
      :description,
      #:disks,
      :metadata
      #:external_ip_address,
      #:internal_ip_address,
      #:wait_until_running,
      #:use_compute_key,
      #:service_account,
      #:service_account_scopes,
      # takes a hash of keys
      #:authorized_user_keys
    ].collect do |attr|
      resource[attr] && "--#{attr}=#{resource[attr]}"
    end.compact
    gcutilcmd('addinstance', resource[:name], args)
  end

  def exists?
   begin
      instance_output = gcutilcmd('getinstance', resource[:name])
   rescue Puppet::ExecutionFailure
      return false
   end
  end

  def destroy
    gcutilcmd('deleteinstance', resource[:name], '-f')
  end

  private

    def self.parse_instances(output)
      (output.split("\n")[3..-2] || []).collect do |i|
        i.split('|').collect {|x| x.strip }
      end
    end

end
