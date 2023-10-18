require 'spec_helper'
require 'tempfile'
require 'pact/consumer_contract/pact_file'
require 'base64' # XXX: https://github.com/bblimke/webmock/pull/611
require "faraday"
require "faraday/retry"

module Pact
  describe PactFile do
    describe 'render_pact' do
      let(:uri_without_userinfo) { 'http://pactbroker.com'}
      let(:redirect_uri_without_userinfo) { 'http://alternate-pactbroker.com'}
      let(:pact_content) { 'api contract'}

      describe 'from a local file URI' do
        let(:temp_file) { Tempfile.new('local-pact-file') }
        let(:file_uri) { temp_file.path }
        let(:local_pact_content) { 'local pact content' }
        before do
          File.write file_uri, local_pact_content
        end
        after do
          temp_file.unlink
        end

        it 'reads from the local file system' do
          expect(PactFile.render_pact(file_uri, {})).to eq(local_pact_content)
        end
      end

      describe 'with backslashes to a local path' do
        let(:windows_path) { 'spec\support\a_consumer-a_provider.json' }
        let(:unix_path) { 'spec/support/a_consumer-a_provider.json' }

        it 'transforms them to forward slashes' do
          expect(PactFile.read(windows_path)).to eq PactFile.read(unix_path)
        end
      end

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

      context 'with a token' do
        let(:token) { 'askfjlksjf'}
        let(:options) { { token: token } }

        let!(:request) do
          stub_request(:get, uri_without_userinfo).with(headers: {'Authorization' => 'Bearer askfjlksjf'}).to_return(body: pact_content)
        end

        it 'sets the Bearer Authorization header' do
          PactFile.render_pact(uri_without_userinfo, options)
          expect(request).to have_been_made
        end

      end

      describe 'retry feature' do
        before { allow(PactFile).to receive(:delay_retry).with(kind_of(Integer)) }

        def render_pact(options = {})
          PactFile.render_pact(uri_without_userinfo, options)
        end

        context 'with client error' do
          before { stub_request(:get, uri_without_userinfo).to_return(status: 400) }

          it 'raises client error without retrying' do
            expect(PactFile).not_to receive(:delay_retry)
            expect { render_pact }.to raise_error(PactFile::HttpError, /status=400/)
          end
        end

        context 'with redirect' do
          before do
            stub_request(:get, uri_without_userinfo).to_return(status: 302, headers: {"location" => redirect_uri_without_userinfo})
            stub_request(:get, redirect_uri_without_userinfo).to_return(status: 200, body: pact_content)
          end

          it 'succeeds' do
            expect(PactFile).not_to receive(:delay_retry)
            expect(render_pact).to eq(pact_content)
          end
        end

        context 'with single server error' do
          before do
            stub_request(:get, uri_without_userinfo).to_return(status: 500).
              then.to_return(status: 200, body: pact_content)
          end

          it 'retries and succeeds' do
            expect(render_pact).to eq(pact_content)
          end
        end

        context 'with continuous server errors' do
          before { stub_request(:get, uri_without_userinfo).to_return(status: 500) }

          it 'retries but failed by retry limit' do
            expect { render_pact }.to raise_error(PactFile::HttpError, /status=500/)
          end
        end

        context 'with single open timeout' do
          before do
            stub_request(:get, uri_without_userinfo).to_raise(Net::OpenTimeout).
              then.to_return(status: 200, body: pact_content)
          end

          it 'retries and succeeds' do
            expect(render_pact).to eq(pact_content)
          end
        end

        context 'with continuous open timeouts' do
          before { stub_request(:get, uri_without_userinfo).to_raise(Net::OpenTimeout) }

          it 'retries but failed by retry limit' do
            expect { render_pact }.to raise_error(Net::OpenTimeout)
          end
        end

        context 'with single read timeout' do
          before do
            stub_request(:get, uri_without_userinfo).to_raise(Net::ReadTimeout).
              then.to_return(status: 200, body: pact_content)
          end

          it 'retries and succeeds' do
            expect(render_pact).to eq(pact_content)
          end
        end

        context 'with continuous read timeout' do
          before { stub_request(:get, uri_without_userinfo).to_raise(Net::ReadTimeout) }

          it 'retries but failed by retry limit' do
            expect { render_pact }.to raise_error(Net::ReadTimeout)
          end
        end

        context 'with retry_limit option and server error' do
          before do
            stub_request(:get, uri_without_userinfo).to_return(status: 500).
              then.to_return(status: 200, body: pact_content)
          end

          it 'retries and succeeds' do
            expect { render_pact(retry_limit: 0) }.to raise_error(PactFile::HttpError, /status=500/)
          end
        end

        context 'with retry_limit option and open timeout error' do
          before do
            stub_request(:get, uri_without_userinfo).to_raise(Net::OpenTimeout).
              then.to_return(status: 200, body: pact_content)
          end

          it 'retries and succeeds' do
            expect { render_pact(retry_limit: 0) }.to raise_error(Net::OpenTimeout)
          end
        end

        context 'with retry_limit option which is greater than default retry limit' do
          before do
            stub_request(:get, uri_without_userinfo).to_return(status: 500).
              then.to_return(status: 500).
              then.to_return(status: 500).
              then.to_return(status: 500).
              then.to_return(status: 200, body: pact_content)
          end

          it 'retries and succeeds' do
            expect(render_pact(retry_limit: 4)).to eq(pact_content)
          end
        end
      end

      describe "x509 certificate" do
        FAKE_SERVER_URL = 'https://localhost:4444'
        X509_CERT_FILE_PATH = './spec/fixtures/certificates/client_cert.pem'
        X509_KEY_FILE_PATH = './spec/fixtures/certificates/key.pem'
        UNSIGNED_X509_CERT_FILE_PATH = './spec/fixtures/certificates/unsigned_cert.pem'
        UNSIGNED_X509_KEY_FILE_PATH = './spec/fixtures/certificates/unsigned_key.pem'

        def wait_for_server_to_start
          Faraday.new(
            url: FAKE_SERVER_URL,
            ssl: {
              verify: false,
              client_cert: OpenSSL::X509::Certificate.new(File.read(X509_CERT_FILE_PATH)),
              client_key: OpenSSL::PKey::RSA.new(File.read(X509_KEY_FILE_PATH))
            }
          ) do |builder|
            builder.request :retry, max: 20, interval: 0.5, exceptions: [StandardError]
            builder.adapter :net_http
          end.get
        end

        let(:render_pact) { PactFile.render_pact(FAKE_SERVER_URL, {}) }

        before(:all) do
          @pipe = IO.popen("bundle exec ruby ./spec/support/ssl_server.rb")
          ENV['SSL_CERT_FILE'] = "./spec/fixtures/certificates/ca_cert.pem"

          wait_for_server_to_start()
        end

        context "with valid x509 client certificates" do
          before do
            ENV['X509_CLIENT_CERT_FILE'] = X509_CERT_FILE_PATH
            ENV['X509_CLIENT_KEY_FILE'] = X509_KEY_FILE_PATH
          end

          it "succeeds" do
            expect(render_pact).to eq("Fake SSL server\n")
          end
        end

        context "when invalid x509 certificates are set" do
          before do
            ENV['X509_CLIENT_CERT_FILE'] = UNSIGNED_X509_CERT_FILE_PATH
            ENV['X509_CLIENT_KEY_FILE'] = UNSIGNED_X509_KEY_FILE_PATH
          end

          it "fails raising SSL error" do
            expect { render_pact }
              .to raise_error { |error|
                expect([OpenSSL::SSL::SSLError, Errno::ECONNRESET]).to include(error.class)
              }
          end
        end

        context "when no x509 certificates are set" do
          before do
            ENV['X509_CLIENT_CERT_FILE'] = nil
            ENV['X509_CLIENT_KEY_FILE'] = nil
          end

          it "fails raising SSL error" do
            expect { render_pact }
              .to raise_error { |error|
                expect([OpenSSL::SSL::SSLError, Errno::ECONNRESET]).to include(error.class)
              }
          end
        end

        after(:all) do
          Process.kill "KILL", @pipe.pid
        end
      end
    end
  end
end
