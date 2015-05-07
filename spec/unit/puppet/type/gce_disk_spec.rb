require 'puppet'
require 'spec_helper'

describe Puppet::Type.type(:gce_disk) do
  let(:params) { [:name,
                  :zone,
                  :description,
                  :size,
                  :image] }

  it "should have expected parameters" do
    expect(described_class.parameters).to match_array(params + [:provider])
  end
end
