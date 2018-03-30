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
  end
end
