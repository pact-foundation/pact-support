require 'spec_helper'
require 'pact/consumer_contract/pact_file'

module Pact
  describe PactFile do
    describe 'render_pact' do
      let(:uri_without_userinfo) { 'http://pactbroker.com'}
      let(:pact_content) { 'api contract'}
      context 'without basic authentication' do
        it 'should open uri to get pact file content' do
          expect(PactFile).to receive(:open).with(uri_without_userinfo, {}).and_return(pact_content)
          expect(PactFile.render_pact(uri_without_userinfo, {})).to eq(pact_content)
        end
      end

      context 'basic authentication' do
        let(:username) { 'brokeruser'}
        let(:password) { 'brokerpassword'}
        let(:options) do
          { username: username, password: password }
        end
        context 'when userinfo is specified in the option' do
          it 'should open uri to get pact file content with userinfo in the options' do
            expect(PactFile).to receive(:open).with(uri_without_userinfo, {http_basic_authentication:[username, password]})
                                .and_return(pact_content)
            expect(PactFile.render_pact(uri_without_userinfo, options)).to eq(pact_content)
          end
          let(:uri_with_userinfo) { 'http://dummyuser:dummyps@pactbroker.com'}
          it 'should use userinfo in options which overwrites userinfo in url' do
            expect(PactFile).to receive(:open).with(uri_without_userinfo, {http_basic_authentication:[username, password]})
                                .and_return(pact_content)
            expect(PactFile.render_pact(uri_with_userinfo, options)).to eq(pact_content)
          end
        end

        context 'when user info is specified in url' do
          let(:uri_with_userinfo) { "http://#{username}:#{password}@pactbroker.com"}
          it 'should open uri to get pact file content with userinfo in the uri' do
            expect(PactFile).to receive(:open).with(uri_without_userinfo, {http_basic_authentication:[username, password]})
                                .and_return(pact_content)
            expect(PactFile.render_pact(uri_with_userinfo, {})).to eq(pact_content)
          end
        end
      end
    end
  end
end