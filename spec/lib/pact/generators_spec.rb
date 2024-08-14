require 'pact/generators'

describe Pact::Generators do
  it 'execute_generators with RandomBoolean' do
    hash = { 'type' => 'RandomBoolean' }
    expect(Pact::Generators.execute_generators(hash)).to eq(true).or eq(false)
  end

  it 'execute_generators with Date' do
    hash = { 'type' => 'Date' }
    expect(Pact::Generators.execute_generators(hash).length).to eq(10)
  end

  it 'execute_generators with DateTime' do
    hash = { 'type' => 'DateTime' }
    expect(Pact::Generators.execute_generators(hash).length).to eq(16)
  end

  it 'execute_generators with ProviderState' do
    hash = { 'type' => 'ProviderState', 'expression' => 'Bearer ${access_token}' }
    params = { 'access_token' => 'ABC' }
    expect(Pact::Generators.execute_generators(hash, params)).to eq('Bearer ABC')
  end

  it 'execute_generators with RandomDecimal' do
    hash = { 'type' => 'RandomDecimal' }
    expect(String(Pact::Generators.execute_generators(hash)).length).to eq(7)
  end

  it 'execute_generators with RandomHexadecimal' do
    hash = { 'type' => 'RandomHexadecimal' }
    expect(Pact::Generators.execute_generators(hash).length).to eq(8)
  end

  it 'execute_generators with RandomInt' do
    hash = { 'type' => 'RandomInt' }
    expect(Pact::Generators.execute_generators(hash).instance_of?(Integer)).to be true
  end

  it 'execute_generators with RandomString' do
    hash = { 'type' => 'RandomString' }
    expect(Pact::Generators.execute_generators(hash).length).to eq(20)
  end

  it 'execute_generators with Regex' do
    hash = { 'type' => 'Regex', 'pattern' => '(one|two)' }
    expect(Pact::Generators.execute_generators(hash)).to eq('one').or eq('two')
  end

  it 'execute_generators with Time' do
    hash = { 'type' => 'Time' }
    expect(Pact::Generators.execute_generators(hash).length).to eq(5)
  end

  it 'execute_generators with Uuid' do
    hash = { 'type' => 'Uuid' }
    expect(Pact::Generators.execute_generators(hash).length).to eq(36)
  end
end
