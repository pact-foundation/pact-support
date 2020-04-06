require 'pact/matching_rules/v3/merge'

describe Pact::MatchingRules::V3::Merge do
  describe ".call" do
    subject { described_class.call(expected, matching_rules) }

    before do
      allow($stderr).to receive(:puts) do |message|
        raise <<-EOS
                Was not expecting stderr to receive #{message.inspect} in this spec.
                This may be because of a missed rule deletion in Merge.
              EOS
      end
    end

    context "no recognised rules" do
      before do
        allow($stderr).to receive(:puts)
      end

      let(:expected) do
        {
          "_links" => {
            "self" => {
              "href" => "http://localhost:1234/thing"
            }
          }
        }
      end

      let(:matching_rules) do
        {
          "$._links.self.href" => {
            "matchers" => [{ "type" => "unknown" }]
          }
        }
      end

      it "returns the object at that path unaltered" do
        expect(subject["_links"]["self"]["href"]).to eq "http://localhost:1234/thing"
      end

      it "logs the rules it has ignored" do
        subject

        expect($stderr).to have_received(:puts) do |message|
          expect(message).to include("WARN")
            .and include("type")
            .and include("unknown")
            .and include("$['_links']")
        end
      end
    end

    context "with nil rules" do
      let(:expected) do
        {
          "_links" => {
            "self" => {
              "href" => "http://localhost:1234/thing"
            }
          }
        }
      end

      let(:matching_rules) { nil }

      it "returns the example unaltered" do
        expect(subject["_links"]["self"]["href"]).to eq "http://localhost:1234/thing"
      end
    end

    context "type based matching" do
      before do
        allow($stderr).to receive(:puts)
      end

      let(:expected) do
        {
          "name" => "Mary"
        }
      end

      let(:matching_rules) do
        {
          "$.name" => {
            "matchers" => [{ "match" => "type", "ignored" => "matchingrule" }]
          }
        }
      end

      it "creates a SomethingLike at the appropriate path" do
        expect(subject['name']).to be_instance_of(Pact::SomethingLike)
      end

      it "it logs the rules it has ignored" do
        subject

        expect($stderr).to have_received(:puts).once.with(/ignored.*matchingrule/)
      end

      it "does not alter the passed in rules hash" do
        original_matching_rules = JSON.parse(matching_rules.to_json)
        subject
        expect(matching_rules).to eq original_matching_rules
      end
    end

    context "when a Pact.like is nested inside a Pact.each_like which is nested inside a Pact.like" do
      let(:original_definition) do
        Pact.like('foos' => Pact.each_like(Pact.like('name' => "foo1")))
      end

      let(:expected) do
        Pact::Reification.from_term(original_definition)
      end

      let(:matching_rules) do
        Pact::MatchingRules::V3::Extract.call(original_definition)
      end

      it "creates a Pact::SomethingLike containing a Pact::ArrayLike containing a Pact::SomethingLike" do
        expect(subject.to_hash).to eq original_definition.to_hash
      end
    end

    context "when a Pact.array_like is the top level object" do
      let(:original_definition) do
        Pact.each_like('foos')
      end

      let(:expected) do
        Pact::Reification.from_term(original_definition)
      end

      let(:matching_rules) do
        Pact::MatchingRules::V3::Extract.call(original_definition)
      end

      it "creates a Pact::ArrayLike" do
        expect(subject.to_hash).to eq original_definition.to_hash
      end
    end

    context "when a Pact.like containing an array is the top level object" do
      let(:original_definition) do
        Pact.like(['foos'])
      end

      let(:expected) do
        Pact::Reification.from_term(original_definition)
      end

      let(:matching_rules) do
        Pact::MatchingRules::V3::Extract.call(original_definition)
      end

      it "creates a Pact::SomethingLike" do
        expect(subject).to be_a(Pact::SomethingLike)
        expect(subject.to_hash).to eq original_definition.to_hash
      end
    end

    describe "regular expressions" do
      context "in a hash" do
        before do
          allow($stderr).to receive(:puts)
        end

        let(:expected) do
          {
            "_links" => {
              "self" => {
                "href" => "http://localhost:1234/thing"
              }
            }
          }
        end

        let(:matching_rules) do
          {
            "$._links.self.href" => {
              "matchers" => [{
                "regex" => "http:\\/\\/.*\\/thing",
                "match" => "regex",
                "ignored" => "somerule"
              }]
            }
          }
        end

        it "creates a Pact::Term at the appropriate path" do
          expect(subject["_links"]["self"]["href"]).to be_instance_of(Pact::Term)
          expect(subject["_links"]["self"]["href"].generate).to eq "http://localhost:1234/thing"
          expect(subject["_links"]["self"]["href"].matcher.inspect).to eq "/http:\\/\\/.*\\/thing/"
        end

        it "logs the rules it has ignored" do
          subject

          expect($stderr).to have_received(:puts) do |message|
            expect(message).to match(/ignored.*"somerule"/)
            expect(message).to_not match(/regex/)
            expect(message).to_not match(/"match"/)
          end
        end
      end

      context "with an array" do
        let(:expected) do
          {
            "_links" => {
              "self" => [{
                "href" => "http://localhost:1234/thing"
              }]
            }
          }
        end

        let(:matching_rules) do
          {
            "$._links.self[0].href" => {
              "matchers" => [{ "regex" => "http:\\/\\/.*\\/thing" }]
            }
          }
        end

        it "creates a Pact::Term at the appropriate path" do
          expect(subject["_links"]["self"][0]["href"]).to be_instance_of(Pact::Term)
          expect(subject["_links"]["self"][0]["href"].generate).to eq "http://localhost:1234/thing"
          expect(subject["_links"]["self"][0]["href"].matcher.inspect).to eq "/http:\\/\\/.*\\/thing/"
        end
      end

      describe "with an ArrayLike containing a Term" do
        let(:expected) do
          ["foo"]
        end

        let(:matching_rules) do
          {
            "$" => {"matchers" => [{"min" => 1}]},
            "$[*].*" => {"matchers" => [{"match" => "type"}]},
            "$[*]" => {"matchers" => [{"match" => "regex", "regex"=>"f"}]}
          }
        end

        it "creates an ArrayLike with a Pact::Term as the contents" do
          expect(subject).to be_a(Pact::ArrayLike)
          expect(subject.contents).to be_a(Pact::Term)
        end
      end
    end

    context "with an array where all elements should match by type and the rule is specified on the parent element and there is no min specified" do
      let(:expected) do
        {
          'alligators' => [{'name' => 'Mary'}]
        }
      end

      let(:matching_rules) do
        {
          "$.alligators" => {
            "matchers" => [{ 'match' => 'type' }]
          }
        }
      end

      it "creates a Pact::SomethingLike at the appropriate path" do
        expect(subject["alligators"]).to be_instance_of(Pact::SomethingLike)
        expect(subject["alligators"].contents).to eq ['name' => 'Mary']
      end
    end

    context "with an array where all elements should match by type and the rule is specified on the child elements" do
      let(:expected) do
        {
          'alligators' => [{'name' => 'Mary'}]
        }
      end

      let(:matching_rules) do
        {
          "$.alligators" => {
            "matchers" => [{ 'min' => 2}]
          },
          "$.alligators[*].*" => {
            "matchers" => [{ 'match' => 'type'}]
          }
        }
      end

      it "creates a Pact::ArrayLike at the appropriate path" do
        expect(subject["alligators"]).to be_instance_of(Pact::ArrayLike)
        expect(subject["alligators"].contents).to eq 'name' => 'Mary'
        expect(subject["alligators"].min).to eq 2
      end
    end

    context "with an array where all elements should match by type and the rule is specified on both the parent element and the child elements" do
      let(:expected) do
        {
          'alligators' => [{'name' => 'Mary'}]
        }
      end

      let(:matching_rules) do
        {
          "$.alligators" => {
            "matchers" => [{ 'min' => 2, 'match' => 'type' }]
          },
          "$.alligators[*].*" => {
            "matchers" => [{ 'match' => 'type' }]
          }
        }
      end

      it "creates a Pact::ArrayLike at the appropriate path" do
        expect(subject["alligators"]).to be_instance_of(Pact::SomethingLike)
        expect(subject["alligators"].contents).to be_instance_of(Pact::ArrayLike)
        expect(subject["alligators"].contents.contents).to eq 'name' => 'Mary'
        expect(subject["alligators"].contents.min).to eq 2
      end
    end

    context "with an array where all elements should match by type and there is only a match:type on the parent element" do
      let(:expected) do
        {
          'alligators' => [{'name' => 'Mary'}]
        }
      end

      let(:matching_rules) do
        {
          "$.alligators" => { 'matchers' => [{'min' => 2, 'match' => 'type'}] }
        }
      end

      it "creates a Pact::ArrayLike at the appropriate path" do
        expect(subject["alligators"]).to be_instance_of(Pact::ArrayLike)
        expect(subject["alligators"].contents).to eq 'name' => 'Mary'
        expect(subject["alligators"].min).to eq 2
      end
    end

    context "with an array where all elements should match by type nested inside another array where all elements should match by type" do
      let(:expected) do
        {

          'alligators' => [
            {
              'name' => 'Mary',
              'children' => [
                'age' => 9
              ]
            }
          ]

        }
      end

      let(:matching_rules) do
        {
          "$.alligators" => { "matchers" => [{ 'min' => 2, 'match' => 'type' }] },
          "$.alligators[*].children" => { "matchers" => [{ 'min' => 1, 'match' => 'type' }]}
        }
      end

      it "creates a Pact::ArrayLike at the appropriate path" do
        expect(subject["alligators"].contents['children']).to be_instance_of(Pact::ArrayLike)
        expect(subject["alligators"].contents['children'].contents).to eq 'age' => 9
        expect(subject["alligators"].contents['children'].min).to eq 1
      end
    end

    context "with an example array with more than one item" do
      before do
        allow($stderr).to receive(:puts)
      end

      let(:expected) do
        {

          'alligators' => [
            {'name' => 'Mary'},
            {'name' => 'Joe'}
          ]
        }
      end

      let(:matching_rules) do
        {
          "$.alligators" => { "matchers" => [{'min' => 2, 'match' => 'type'}] }
        }
      end

      it "doesn't warn about the min size being ignored" do
        subject

        expect(Pact.configuration.error_stream).to have_received(:puts).once
      end

      it "warns that the other items will be ignored" do
        allow(Pact.configuration.error_stream).to receive(:puts)

        subject

        expect(Pact.configuration.error_stream).to have_received(:puts)
          .with(/WARN: Only the first item/)
      end
    end

    context "using bracket notation for a Hash" do
      let(:expected) do
        {
          "name" => "Mary"
        }
      end

      let(:matching_rules) do
        {
          "$['name']" => { "matchers" => [{ "match" => "type" }] }
        }
      end

      it "applies the rule" do
        expect(subject['name']).to be_instance_of(Pact::SomethingLike)
      end
    end

    describe "with a dot in the path" do
      let(:expected) do
        {
          "first.name" => "Mary"
        }
      end

      let(:matching_rules) do
        {
          "$['first.name']" => { "matchers" => [{ "match" => "type" }] }
        }
      end

      it "applies the rule" do
        expect(subject['first.name']).to be_instance_of(Pact::SomethingLike)
      end
    end

    context "with an @ in the path" do
      let(:expected) do
        {
          "@name" => "Mary"
        }
      end

      let(:matching_rules) do
        {
          "$['@name']" => { "matchers" => [{ "match" => "type" }] }
        }
      end

      it "applies the rule" do
        expect(subject['@name']).to be_instance_of(Pact::SomethingLike)
      end
    end

    context "with a combine key" do
      let(:expected) do
        {
          "foo" => "bar"
        }
      end

      let(:matching_rules) do
        {
          "$.foo" => {
            "matchers" => [{ "match" => "type" }],
            "combine" => "AND"
          }
        }
      end

      it "logs the ignored rule" do
        allow(Pact.configuration.error_stream).to receive(:puts)

        subject

        expect(Pact.configuration.error_stream).to have_received(:puts)
          .with("WARN: Ignoring unsupported combine AND for path $['foo']")
      end
    end

    context "when the top level object is a string" do
      before do
        allow(Pact.configuration.error_stream).to receive(:puts)
      end

      let(:expected) do
        "/some/path"
      end

      let(:matching_rules) do
        {
          "$." => {
            "matchers" => [{ "match" => "type" }],
            "combine" => "AND"
          }
        }
      end

      it "returns a SomethingLike" do
        expect(subject).to eq Pact::SomethingLike.new("/some/path")
      end
    end

    context "when there are no matchers" do
      let(:expected) do
        {
          "name" => "Mary"
        }
      end

      let(:matching_rules) do
        {
          "$.name" => {}
        }
      end

      it "does not blow up" do
        subject
      end
    end
  end
end
