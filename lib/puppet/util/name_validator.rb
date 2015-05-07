module Puppet::Util
  class NameValidator
    def self.validate(v)
      unless v =~ /^[a-z]([-a-z0-9]{0,61}[a-z0-9])$/
        fail("Invalid disk name: #{v}.  Must be a match of regex /^[a-z]([-a-z0-9]{0,61}[a-z0-9])$/.")
      end
    end
  end
end
