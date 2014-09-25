require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))

Puppet::Type.type(:gce_auth).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  mk_resource_methods
  
  def self.parameter_list
    [ :project, :client_email, :key_file ]
  end

  def create
    self.class.superclass.project = resource[:project] if resource[:project]
    self.class.superclass.client_email = resource[:client_email] \
      if resource[:client_email]
    self.class.superclass.key_file = resource[:key_file] if resource[:key_file]
  end

  # This is so that the parent class's prefetch method is not called
  def self.prefetch(resources)
    nil
  end

end
