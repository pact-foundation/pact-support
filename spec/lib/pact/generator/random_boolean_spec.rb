require 'pact/generator/random_boolean'

describe Pact::Generator::RandomBoolean do
  generator = Pact::Generator::RandomBoolean.new

  it 'can_generate with a supported hash' do
    hash = { 'type' => 'RandomBoolean' }
    expect(generator.can_generate?(hash)).to be true
  end

  it 'can_generate with a unsupported hash' do
    hash = { 'type' => 'unknown' }
    expect(generator.can_generate?(hash)).to be false
  end

  it 'call' do
    hash = { 'type' => 'RandomBoolean' }
    expect(generator.call(hash)).to eq(true).or eq(false)
  end
end
