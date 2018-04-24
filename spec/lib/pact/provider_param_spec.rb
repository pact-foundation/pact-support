require 'spec_helper'
require 'byebug'

module Pact
  describe ProviderParam do

    describe 'initialize' do
      it 'creates a ProviderParam' do
        pp = ProviderParam.new(['/some/url/with/', Var.new(:a_var, 'variable')])
        expect(pp).to be_instance_of(Pact::ProviderParam)
      end
    end

    describe 'default_string' do
      it 'returns the default string' do
        pp = ProviderParam.new(['/some/url/with/', Var.new(:a_var, 'variable')])
        expect(pp.default_string).to eq('/some/url/with/variable')
      end
    end

    describe 'fill_string' do
      it 'returns the fill string' do
        pp = ProviderParam.new(['/some/', Var.new(:var, 'var'), '/here', Var.new(:blah, 'aoeu')])
        expect(pp.fill_string).to eq('/some/:{var}/here:{blah}')
        expect(pp.default_string).to eq('/some/var/hereaoeu')
      end
    end

    describe 'initialize with fill string' do
      it 'finds the param names' do
        pp = ProviderParam.new('/some/:{id}/path_:{here}', {id: 5, here: 'something'})
      end
    end
  end
end
