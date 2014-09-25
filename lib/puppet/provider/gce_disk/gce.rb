require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gce'))
# TODO: add support for disk images as source
Puppet::Type.type(:gce_disk).provide(
  :fog,
  :parent => Puppet::Provider::Gce
) do

  mk_resource_methods
  
  def self.subtype
    superclass.connection.disks
  end

  def subtype
    self.class.subtype
  end

  #Add more params here later when needed
  def self.parameter_list
    [:zone, :size_gb, :description, :wait_until_complete, :source_image,
      :async_destroy, :async_create ]
  end

  def self.os_images
    self.get_os_images unless @os_images
    @os_images
  end

  def self.get_os_images
    images = superclass.connection.images.all
    @os_images = []
    images.each {|img|
      @os_images << img.name if img.deprecated.nil?
    }
  end

  # TODO Check the project for images before checking the image array
  def init_create
    # Find the fully qualified image name if a partial name was given
    if resource[:source_image]
      foundImages = []
      self.class.os_images.each {|img|
        foundImages << img if img.match('^' + resource[:source_image])
      }
      raise(Puppet::Error, "Unable to disambiguate disk image #{resource[:source_iamge]}. Please be more specific.") if foundImages.length > 1
      resource[:source_image] = foundImages[0]
    end
    nil
  end

end
