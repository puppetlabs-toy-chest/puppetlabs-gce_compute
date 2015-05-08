require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_network) do
  let(:params) { [:name,
                  :description,
                  :range] }
  let(:create_params) { {:name => 'name', :region => 'region'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"
end
