require 'pact/provider_param'

module Pact
  describe Matchers do

    let(:expected) do
      {
        url: Pact::ProviderParam.new('/some/:{url_var}/here', {url_var: 'url'})
      }
    end

    it 'should not have a difference' do
      actual = {
        url: '/some/url/here'
      }
      expect(Pact::Matchers.diff(expected, actual)).to be_empty
    end
  end
end
