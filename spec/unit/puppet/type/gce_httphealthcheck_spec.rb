require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_httphealthcheck) do
  let(:params) { [:name,
                  :description,
                  :check_interval,
                  :timeout,
                  :healthy_threshold,
                  :host,
                  :port,
                  :request_path,
                  :unhealthy_threshold] }
  let(:create_params) { {:name => 'name'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"
end
