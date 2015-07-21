require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_firewallrule) do
  let(:params) { [:name,
                  :description,
                  :allow,
                  :network,
                  :source_ranges,
                  :source_tags,
                  :target_tags] }
  let(:create_params) { {:name => 'name'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"
end
