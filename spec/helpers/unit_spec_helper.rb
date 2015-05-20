# Shared examples for type specs

RSpec.shared_examples "a resource with expected parameters" do
  it "should have expected parameters" do
    expect(described_class.parameters).to match_array(params + [:provider])
  end
end

RSpec.shared_examples "it has a validated name" do
  it "should be invalid without a name" do
    create_params[:name] = nil
    expect { described_class.new(create_params) }.to raise_error(/Title or name/)
  end

  it "should be invalid with an invalid name" do
    create_params[:name] = 'invalid-name-'
    expect { described_class.new(create_params) }.to raise_error(/Invalid name/)
  end
end

# Shared examples for provider specs

RSpec.shared_examples "a resource that can be created" do
  it "should return nil when a resource is created" do
    expect(provider).to receive(:gcloud).with(*gcloud_base_params + gcloud_additional_params)
    expect(provider.create).to be_nil
  end

  it "should raise an exception when creating a resource that already exists" do
    expect(provider).to receive(:gcloud).with(*gcloud_base_params + gcloud_additional_params).and_raise(Puppet::ExecutionFailure.new(''))
    expect { provider.create }.to raise_error(Puppet::ExecutionFailure)
  end
end
