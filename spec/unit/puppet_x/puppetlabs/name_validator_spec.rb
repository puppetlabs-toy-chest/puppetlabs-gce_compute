require 'spec_helper'

describe PuppetX::Puppetlabs::NameValidator do
  describe "#validate" do
    it "raises an error for an invalid name" do
      ['123', 'aaa-', 'a_a', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', "\naaa"].each do |v|
        expect { described_class.validate(v) }.to raise_error(/Invalid name: #{v}.  Must be a match of regex/)
      end
    end

    it "does not raise an error for a valid name" do
      expect { described_class.validate('valid-name') }.not_to raise_error
    end
  end
end
