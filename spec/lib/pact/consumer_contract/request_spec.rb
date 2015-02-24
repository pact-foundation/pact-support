require 'spec_helper'
require 'pact/consumer_contract/request'
require 'pact/consumer/request'
require 'support/shared_examples_for_request'

module Pact

  describe Request::Expected do
    it_behaves_like "a request"

    let(:raw_request) do
      {
        'method' => 'get',
        'path' => '/mallory'
      }
    end

    describe "from_hash" do
      context "when optional field are not defined" do
        subject { described_class.from_hash(raw_request) }
        it "sets their values to NullExpectation" do
          expect(subject.body).to be_instance_of(Pact::NullExpectation)
          expect(subject.query).to be_instance_of(Pact::NullExpectation)
          expect(subject.headers).to be_instance_of(Pact::NullExpectation)
        end
      end
    end

    describe "matches_route?" do
      context "when the case of the method is different but the path is the same" do
        subject { Request::Expected.from_hash(method: 'get', path: '/') }
        let(:other) { Consumer::Request::Actual.from_hash(method: 'get', path: '/', query: nil, headers: {}) }

        it "returns true" do
          expect(subject.matches_route?(other)).to be true
        end
      end

      context "when the path is a Pact::Term" do
        subject { Request::Expected.from_hash(method: 'get', path: Pact::Term.new(matcher: %r{/alligators/.*}, generate: '/alligators/Mary')) }
        let(:other) { Consumer::Request::Actual.from_hash(method: 'get', path: '/alligators/John', query: nil, headers: {}) }

        it "returns true" do
          expect(subject.matches_route?(other)).to be true
        end
      end
    end

    describe "matching to actual requests" do

      subject { Request::Expected.new(expected_method, expected_path, expected_headers, expected_body, expected_query, options) }
      let(:options) { {} }

      let(:expected_method) { 'get' }
      let(:expected_path) { '/foo' }
      let(:expected_headers) { Pact::NullExpectation.new }
      let(:expected_body) { Pact::NullExpectation.new }
      let(:expected_query) { '' }

      let(:actual_request) { Consumer::Request::Actual.new(actual_method, actual_path, actual_headers, actual_body, actual_query) }

      let(:actual_method) { 'get' }
      let(:actual_path) { '/foo' }
      let(:actual_headers) { {} }
      let(:actual_body) { '' }
      let(:actual_query) { '' }

      it "matches identical requests" do
        expect(subject.matches? actual_request).to be true
      end

      context "when the Content-Type header is a Pact::Term" do
        let(:expected_headers) { {'Content-Type' => Pact::Term.new(generate: 'application/json', matcher: /json/) } }
        let(:expected_body) { {'foo' => 'bar'} }
        let(:actual_headers) { {'Content-Type' => 'foo/json'} }
        let(:actual_body) { {'foo' => 'bar'} }

        it "reifies the term before matching" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the methods are the same but one is symbolized" do
        let(:expected_method) { :get }
        let(:actual_method) { 'get' }

        it "matches" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the methods are different" do
        let(:expected_method) { 'get' }
        let(:actual_method) { 'post' }

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the methods are the same but different case" do
        let(:expected_method) { 'get' }
        let(:actual_method) { 'GET' }

        it "matches" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the paths are different" do
        let(:expected_path) { '/foo' }
        let(:actual_path) { '/bar' }

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the paths vary only by a trailing slash" do
        let(:expected_path) { '/foo' }
        let(:actual_path) { '/foo/' }

        it "matches" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the expected body is nil and the actual body is empty" do
        let(:expected_body) { nil }
        let(:actual_body) { '' }

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the expected body has no expectation and the actual body is empty" do
        let(:expected_body) { Pact::NullExpectation.new }
        let(:actual_body) { '' }

        it "matches" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the expected body is nested and the actual body is nil" do
        let(:expected_body) do
          {
            a: 'a'
          }
        end

        let(:actual_body) { nil }

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the bodies are different" do
        let(:expected_body) { 'foo' }
        let(:actual_body) { 'bar' }

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the expected body contains matching regexes" do
        let(:expected_body) do
          {
            name: 'Bob',
            customer_id: /CN.*/
          }
        end

        let(:actual_body) do
          {
            name: 'Bob',
            customer_id: 'CN1234'
          }
        end

        it "matches" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the expected body contains non-matching regexes" do
        let(:expected_body) do
          {
            name: 'Bob',
            customer_id: /foo/
          }
        end

        let(:actual_body) do
          {
            name: 'Bob',
            customer_id: 'CN1234'
          }
        end

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the expected body contains matching terms" do
        let(:expected_body) do
          {
            name: 'Bob',
            customer_id: Term.new(matcher: /CN.*/, generate: 'CN789')
          }
        end

        let(:actual_body) do
          {
            name: 'Bob',
            customer_id: 'CN1234'
          }
        end

        it "matches" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the expected body contains non-matching terms" do
        let(:expected_body) do
          {
            name: 'Bob',
            customer_id: Term.new(matcher: /foo/, generate: 'fooool')
          }
        end

        let(:actual_body) do
          {
            name: 'Bob',
            customer_id: 'CN1234'
          }
        end

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the expected body contains non-matching arrays" do
        let(:expected_body) do
          {
            name: 'Robert',
            nicknames: ['Bob', 'Bobert']
          }
        end

        let(:actual_body) do
          {
            name: 'Bob',
            nicknames: ['Bob']
          }
        end

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end
      context "when the expected body contains non-matching hash where one field contains a substring of the other" do
          let(:expected_body) do
            {
              name: 'Robert',
            }
          end

          let(:actual_body) do
            {
              name: 'Rob'
            }
          end

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
      end

      context "when the expected body contains matching arrays" do
        let(:expected_body) do
          {
            name: 'Robert',
            nicknames: ['Bob', 'Bobert']
          }
        end

        let(:actual_body) do
          {
            name: 'Robert',
            nicknames: ['Bob', 'Bobert']
          }
        end

        it "does not match" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the queries are different" do
        let(:expected_query) { 'foo' }
        let(:actual_query) { 'bar' }

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context 'when there is no query expectation' do
        let(:expected_query) { Pact::NullExpectation.new }
        let(:actual_query) { 'bar' }

        it 'matches' do
          expect(subject.matches? actual_request).to be true
        end
      end

      context 'when a query is specified' do
        context 'when the queries are defined by hashes, order does not matter' do
          let(:expected_query) { { params: 'hello', params2: 'world', params3: 'small' } }
          let(:actual_query) { 'params3=small&params2=world&params=hello'  }

          it "does match" do
            expect(subject.matches? actual_request).to be true
          end
        end

        context 'when the queries are defined by hashes, order does not matter but content does' do
          let(:expected_query) { { params: 'hello', params2: 'world', params3: 'small' } }
          let(:actual_query) { 'params3=big&params2=world&params=hello' }

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context 'when the queries are defined by hashes, with extra unmatched parameters' do
          let(:expected_query) { { params: 'hello', params2: 'world', params3: 'small' } }
          let(:actual_query) { 'params2=world&params=hello' }

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context 'when the queries are defined by hashes holding Pact Terms, order does not matter but content does' do
          let(:expected_query) { { params: 'hello', params2: Term.new(generate: 'world', matcher: /w\w+/), params3: 'small' } }
          let(:actual_query) { 'params3=small&params=hello&params2=wroom'}

          it "does match" do
            expect(subject.matches? actual_request).to be true
          end
        end

        context 'when the queries are defined by hashes holding Pact Terms and the regex does not match' do
          let(:expected_query) { { params: 'hello', params2: Term.new(generate: 'world', matcher: /w\w+/), params3: 'small' } }
          let(:actual_query) { 'params3=small&params=hello&params2=bonjour'}

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context 'when the query is a hash containing arrays, to denote multiple parameters with the same name' do
          let(:expected_query) {
            { simple_param: "hi",
              double_param: ["hello", "world"],
              simple2: "bye",
            }
          }
          context 'when the multipe terms are in the correct order - order 1' do
            let(:actual_query) {['simple_param=hi', 'double_param=hello', 'double_param=world', 'simple2=bye'].join('&')}
            it "does match" do
              expect(subject.matches? actual_request).to be true
            end
          end
          context 'when the multipe terms are in the correct order - order 2' do
            let(:actual_query) {['simple_param=hi', 'double_param=hello', 'simple2=bye', 'double_param=world'].join('&')}
            it "does match" do
              expect(subject.matches? actual_request).to be true
            end
          end
          context 'when the multipe terms are in the correct order - order 3' do
            let(:actual_query) {['simple2=bye', 'double_param=hello', 'double_param=world', 'simple_param=hi'].join('&')}
            it "does match" do
              expect(subject.matches? actual_request).to be true
            end
          end
          context 'when the multiple terms are in incorrect order' do
            let(:actual_query) {['simple2=bye', 'double_param=world', 'double_param=hello', 'simple_param=hi'].join('&')}
            it "does not match" do
              expect(subject.matches? actual_request).to be false
            end
          end
          context 'when the first of the multiple terms is missing' do
            let(:actual_query) {['simple_param=hi', 'double_param=world', 'simple2=bye', ].join('&')}
            it "does not match" do
              expect(subject.matches? actual_request).to be false
            end
          end
          context 'when the last of the multiple terms is missing' do
            let(:actual_query) {['simple_param=hi', 'double_param=hello', 'simple2=bye', ].join('&')}
            it "does not match" do
              expect(subject.matches? actual_request).to be false
            end
          end
        end

        context 'when the query does not contain multiple params of the same name, but the request does' do
          let(:expected_query) { {param1: 'hi', param2: 'there'} }
          context 'when the param is duplicated' do
            let(:actual_query) { 'param1=hi&param2=there&param2=there'}
            it "does not match" do
              expect(subject.matches? actual_request).to be false
            end
          end
          context 'when the duplicated param has different values' do
            let(:actual_query) { 'param1=hi&param2=there&param2=overthere' }
            it "does not match" do
              expect(subject.matches? actual_request).to be false
            end
          end
        end
      end

      context "when in the body a string is expected, but a number is found" do
        let(:actual_body) { { thing: 123} }
        let(:expected_body) { { thing: "123" } }

        it 'does not match' do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when unexpected keys are found in the body" do
        let(:expected_body) { {a: 1} }
        let(:actual_body) { {a: 1, b: 2} }
        context "when allowing unexpected keys" do
          let(:options) { {'allow_unexpected_keys_in_body' => true} } #From json, these will be strings
          it "matches" do
            expect(subject.matches? actual_request).to be true
          end
        end
        context "when not allowing unexpected keys" do
          let(:options) { {'allow_unexpected_keys_in_body' => false} }
          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end
      end
    end
  end
end