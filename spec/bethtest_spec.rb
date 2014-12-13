require 'pact/matchers/matchers'

describe "thing" do

  include Pact::Matchers

  let(:expected) do
    {
      'a' => 'thing'
    }
  end

  let(:actual) do
    {
      'a' => 'thingo'
    }
  end

  let(:difference) { diff(expected, actual) }

  it "something" do
    puts JSON.pretty_generate(difference)
  end

end