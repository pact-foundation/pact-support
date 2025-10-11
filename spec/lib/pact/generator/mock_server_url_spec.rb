require 'pact/generator/mock_server_url'

describe Pact::Generator::MockServerURL do
  let(:generator) { Pact::Generator::MockServerURL.new }

  describe '#can_generate?' do
    it 'returns true for a supported hash' do
      hash = { 'type' => 'MockServerURL' }
      expect(generator.can_generate?(hash)).to be true
    end

    it 'returns false for an unsupported hash' do
      hash = { 'type' => 'RandomHexadecimal' }
      expect(generator.can_generate?(hash)).to be false
    end
  end

  describe '#call' do
    let(:regex) { '(https://mockserver\.example\.com)' }
    let(:example) { 'https://mockserver.example.com/path' }

    it 'returns the matched group from the example if regex matches' do
      hash = { 'type' => 'MockServerURL', 'regex' => regex, 'example' => example }
      expect(generator.call(hash)).to eq('https://mockserver.example.com')
    end

    it 'returns the example if regex does not match' do
      hash = { 'type' => 'MockServerURL', 'regex' => '(https://another\.com)', 'example' => example }
      expect(generator.call(hash)).to eq(example)
    end

    it 'returns empty string and logs warning if example is missing' do
      hash = { 'type' => 'MockServerURL', 'regex' => regex }
      expect(generator.call(hash)).to eq('')
    end

    it 'returns empty string and logs warning if regex is missing' do
      hash = { 'type' => 'MockServerURL', 'example' => example }
      expect(generator.call(hash)).to eq('')
    end
  end
end
