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
