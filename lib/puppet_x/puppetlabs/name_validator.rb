module PuppetX
  module Puppetlabs
    class NameValidator
      def self.validate(v)
        unless v =~ /\A[a-z]([-a-z0-9]{0,61}[a-z0-9])\Z/
          fail("Invalid name: #{v}.  Must be a match of regex /^[a-z]([-a-z0-9]{0,61}[a-z0-9])$/.")
        end
      end
    end
  end
end
