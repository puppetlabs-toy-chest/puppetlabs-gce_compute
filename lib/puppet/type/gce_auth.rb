Puppet::Type.newtype(:gce_auth) do
  desc 'authentication'

  ensurable do
    newvalue(:present) do
      provider.create
    end
    defaultto :present
  end

  newparam(:project, :namevar => true) do
    validate do |value|
      unless value =~ /^[a-z][-a-z0-9]{5,28}[a-z0-9]\Z/
        raise(Puppet::Error, "Invalid project name: #{value}") 
      end
    end
  end 

  newparam(:client_email) do
    desc 'Email of service account'
  end

  newparam(:key_file) do
    desc 'Location of .p12 file'
  end

end
