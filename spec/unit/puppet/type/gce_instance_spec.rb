require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:gce_instance) do
  let(:params) { [:name,
                  :zone,
                  :address,
                  :can_ip_forward,
                  :description,
                  :boot_disk,
                  :image,
                  :machine_type,
                  :metadata,
                  :network,
                  :maintenance_policy,
                  :scopes,
                  :startup_script,
                  :block_for_startup_script,
                  :startup_script_timeout,
                  :tags,
                  :puppet_master,
                  :puppet_service,
                  :puppet_manifest,
                  :puppet_modules,
                  :puppet_module_repos] }
  let(:create_params) { {:name => 'name', :zone => 'zone'} }

  it_behaves_like "a resource with expected parameters"
  it_behaves_like "it has a validated name"

  it "should be invalid without a zone" do
    expect { described_class.new({:name => 'name'}) }.to raise_error(/zone/)
  end

  it "should be invalid if given block_for_startup_script without a startup_script" do
    expect { described_class.new({:name => 'name',
                                  :zone => 'zone',
                                  :block_for_startup_script => true}) }.to raise_error(/block_for_startup_script/)
  end

  it "should be invalid if given startup_script_timeout without block_for_startup_script" do
    expect { described_class.new({:name => 'name',
                                  :zone => 'zone',
                                  :startup_script_timeout => 10}) }.to raise_error(/block_for_startup_script/)
  end

  it "should valid if given a startup_script, block_for_startup_script, and startup_script_timeout" do
    expect { described_class.new({:name => 'name',
                                  :zone => 'zone',
                                  :startup_script => 'some_startup_script',
                                  :block_for_startup_script => true,
                                  :startup_script_timeout => 10}) }.not_to raise_error
  end

  it "should be valid if given a valid puppet_service" do
    expect { described_class.new({:name => 'name',
                                  :zone => 'zone',
                                  :puppet_service => 'present'}) }.not_to raise_error
  end

  it "should be invalid if given puppet_service that isn't absent or present" do
    expect { described_class.new({:name => 'name',
                                  :zone => 'zone',
                                  :puppet_service => 'hello'}) }.to raise_error(/puppet_service/)
  end

  it "should munge startup_script_timeout to a Float" do
    expect(described_class.new({:name => 'name',
                                :zone => 'zone',
                                :startup_script => 'some_startup_script',
                                :block_for_startup_script => true,
                                :startup_script_timeout => 10})[:startup_script_timeout]).to be_an_instance_of(Float)
  end

  it "should munge puppet_modules to a space-separated string" do
    expect(described_class.new({:name => 'name',
                                :zone => 'zone',
                                :puppet_modules => ['module1', 'module2']})[:puppet_modules]).to eq('module1 module2')
  end

  it "should munge puppet_module_repos to a properly-formatted space-separated string" do
    expect(described_class.new({:name => 'name',
                                :zone => 'zone',
                                :puppet_module_repos => {'module1' => 'git1',
                                                         'module2' => 'git2'}})[:puppet_module_repos]).to eq('git1#module1 git2#module2')
  end
end
