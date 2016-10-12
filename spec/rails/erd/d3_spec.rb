require "spec_helper"

describe Rails::Erd::D3 do
  it "has a version number" do
    expect(Rails::Erd::D3::VERSION).not_to be nil
  end

  it "returns a Rails major version" do
    expect(Rails::VERSION::MAJOR).to eq(Rails::Erd::D3.get_rails_version)
  end
end
