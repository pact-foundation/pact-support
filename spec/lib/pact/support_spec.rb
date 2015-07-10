require 'pact/support'

describe Pact do

  it "includes the Pact::Helpers" do
    expect(Pact).to respond_to(:each_like)
  end

end
