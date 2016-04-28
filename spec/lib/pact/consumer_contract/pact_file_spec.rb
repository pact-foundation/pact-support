require 'spec_helper'
require 'pact/consumer_contract/pact_file'
require 'base64' # XXX: https://github.com/bblimke/webmock/pull/611

module Pact
  describe PactFile do
    describe 'render_pact' do
      let(:uri_without_userinfo) { 'http://pactbroker.com'}
      let(:pact_content) { 'api contract'}
      context 'without basic authentication' do
        before do
          stub_request(:get, uri_without_userinfo).to_return(body: pact_content)
        end

        it 'should open uri to get pact file content' do
          expect(PactFile.render_pact(uri_without_userinfo, {})).to eq(pact_content)
        end
      end

      context 'basic authentication' do
        let(:username) { 'brokeruser'}
        let(:password) { 'brokerpassword'}
        let(:options) do
          { username: username, password: password }
        end
        before do
          stub_request(:get, uri_without_userinfo).with(basic_auth: [username, password]).to_return(body: pact_content)
        end

        context 'when userinfo is specified in the option' do
          it 'should open uri to get pact file content with userinfo in the options' do
            expect(PactFile.render_pact(uri_without_userinfo, options)).to eq(pact_content)
          end

          let(:uri_with_userinfo) { 'http://dummyuser:dummyps@pactbroker.com'}

          it 'should use userinfo in options which overwrites userinfo in url' do
            expect(PactFile.render_pact(uri_with_userinfo, options)).to eq(pact_content)
          end
        end

        context 'when user info is specified in url' do
          let(:uri_with_userinfo) { "http://#{username}:#{password}@pactbroker.com"}

          it 'should open uri to get pact file content with userinfo in the uri' do
            expect(PactFile.render_pact(uri_with_userinfo, {})).to eq(pact_content)
          end
        end
      end
    end
  end
end
