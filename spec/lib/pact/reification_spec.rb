require 'spec_helper'

module Pact
  describe Reification do

    let(:response_spec) do
      {
        woot: /x/,
        britney: 'britney',
        nested: { foo: /bar/, baz: 'qux' },
        my_term: Term.new(generate: 'wiffle', matcher: /^wif/),
        jwt: Jwt.new({foo: 'john'}, 'JWT_KEY','HS256'),
        nested_jwt:  Jwt.new({foo: Term.new(generate: 'wiffle', matcher: /^wif/)}, 'JWT_KEY','HS256'),
        array: ['first', /second/]
      }
    end

    describe "from term" do

      subject { Reification.from_term(response_spec) }

      it "converts regexes into real data" do
        expect(subject[:woot]).to eql 'x'
      end

      it "converts terms into real data" do
        expect(subject[:my_term]).to eql 'wiffle'
      end

      it "passes strings through" do
        expect(subject[:britney]).to eql 'britney'
      end

      it "handles nested hashes" do
        expect(subject[:nested]).to eql({ foo: 'bar', baz: 'qux' })
      end

      it "handles arrays" do
        expect(subject[:array]).to eql ['first', 'second']
      end

      it "handles jwt" do
        expect(subject[:jwt]).to eql 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmb28iOiJqb2huIn0.HWnd4KMrX6QyzQ78P93t-avWabIrURe6aX1M6Nh1Jn4'
      end

      it "handles nested jwt" do
        expect(subject[:nested_jwt]).to eql 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmb28iOiJ3aWZmbGUifQ.FFQQzR6BEuNWZnTlVYjo3zR-rs6Sl_p3lU2EDdTkpE8'
      end
    end

    context "when reifying a Request" do

      let(:request){ Pact::Request::Expected.from_hash(method: 'get', path: '/', body: Pact::Term.new(generate: "sunny", matcher: /sun/))}

      subject { Reification.from_term(request) }

      it "turns it into a hash before reifying it" do
        expect(subject[:body]).to eq("sunny")
      end

    end

    context "when SomethingLike" do

      let(:request) { Pact::SomethingLike.new({a: 'String'})}

      subject { Reification.from_term(request)}

      it "returns the contents of the SomethingLike" do
        expect(subject).to eq({a: 'String'})
      end

    end

    context "when nested SomethingLike" do

      let(:request) {
        Pact::SomethingLike.new(
          {
            a: 'String',
            b: Pact::SomethingLike.new(
              c: 'NestedString'
            )
          }
        )
      }

      subject { Reification.from_term(request)}

      it "returns the contents of the SomethingLike" do
        expect(subject).to eq({a: 'String', b: { c: 'NestedString' }})
      end

    end

    context "when ArrayLike" do

      let(:request) { Pact::ArrayLike.new({a: 'String'}, {min: 3})}

      subject { Reification.from_term(request)}

      it "returns the contents of the ArrayLike" do
        expect(subject).to eq([{a: 'String'}, {a: 'String'}, {a: 'String'}])
      end

    end

    context "when Query" do

      let(:query) { QueryString.new(Pact::Term.new(generate: "param=thing", matcher: /param=.*/)) }

      subject { Reification.from_term(query)}

      it "returns the contents of the generate" do
        expect(subject).to eq("param=thing")
      end

    end

    context "when Hash Query" do

      subject { Reification.from_term(query)}

      let(:query) { QueryHash.new( {param: 'hello', extra: 'world'})}

      it "returns the hash in the natural order" do
        expect(subject).to eq("param=hello&extra=world")
      end
    end

    context "when Hash Query with UTF-8 string" do

      subject { Reification.from_term(query)}

      let(:query) { QueryHash.new( {param: 'ILove', extra: '寿司'})}

      it "returns the hash with escaping UTF-8 string" do
        expect(subject).to eq("param=ILove&extra=%E5%AF%BF%E5%8F%B8")
      end
    end

    context "when Hash Query with embeded terms" do

      subject { Reification.from_term(query)}

      let(:query) { QueryHash.new( {param: 'hello', extra: Pact::Term.new(generate: "wonderworld", matcher: /\w+world/)})}

      it "returns the hash in the natural order, and fills in Terms appropriately" do
        expect(subject).to eq("param=hello&extra=wonderworld")
      end

    end
    context "when Hash Query with Arrays and multiple params with the same name" do

      subject { Reification.from_term(query)}

      let(:query) { QueryHash.new( {param: 'hello', double: [Pact::Term.new(generate: "wonder", matcher: /\w+/), 'world'], simple: 'bye'})}

      it "returns the hash in the natural order, and fills in Terms appropriately" do
        expect(subject).to eq("param=hello&double=wonder&double=world&simple=bye")
      end

    end

  end
end
