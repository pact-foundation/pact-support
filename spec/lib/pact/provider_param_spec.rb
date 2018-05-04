require 'spec_helper'

module Pact
  describe ProviderParam do

    describe 'initialize' do
      it 'creates a ProviderParam' do
        pp = ProviderParam.new('/some/url/with/:{param}', {param: 'a parameter'})
        expect(pp).to be_instance_of(Pact::ProviderParam)
      end
    end

    describe 'default_string' do
      it 'returns the default string' do
        pp = ProviderParam.new('/some/url/with/:{param}', {param: 'a parameter'})
        expect(pp.default_string).to eq('/some/url/with/a parameter')
      end
    end

    describe 'fill_string' do
      it 'returns the fill string' do
        pp = ProviderParam.new('/some/:{var}/here:{blah}', {var: 'var', blah: 'aoeu'})
        expect(pp.fill_string).to eq('/some/:{var}/here:{blah}')
        expect(pp.default_string).to eq('/some/var/hereaoeu')
      end
    end

    describe 'initialize with fill string' do
      it 'finds the param names' do
        pp = ProviderParam.new('/some/:{id}/path_:{here}', {id: '5', here: 'something'}) # TODO make 5 an int
        expect(pp.params).to eq({'id' => '5', 'here' => 'something'})
      end

      it 'finds the param names from a given default string' do
        pp = ProviderParam.new('/some/:{id}/path_:{here}', '/some/4/path_blah')
        expect(pp.params).to eq({'id' => '4', 'here' => 'blah'}) # TODO: symbols?
      end
    end
  end
end
