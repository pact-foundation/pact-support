require 'pact/helpers'

module Pact
  describe Helpers do

    include Pact::Helpers

    describe "#term" do

      context "with a Hash argument" do
        it "creates a Pact::Term" do
          expect(term(generate: 'food', matcher: /foo/)).to eq Pact::Term.new(generate: 'food', matcher: /foo/)
        end
      end

      context "with a Regexp and a String" do
        it "creates a Pact::Term" do
          expect(term(/foo/, 'food')).to eq Pact::Term.new(generate: 'food', matcher: /foo/)
        end
      end

      context "with a String and a Regexp" do
        it "creates a Pact::Term" do
          expect(term('food', /foo/)).to eq Pact::Term.new(generate: 'food', matcher: /foo/)
        end
      end

      context "with anything else" do
        it "raises an ArgumentError" do
          expect{ term(1, /foo/) }.to raise_error(ArgumentError, /Cannot create.*1.*foo/)
        end
      end
    end

    describe "#like" do
      it "creates a Pact::SomethingLike" do
        expect(like(1)).to eq Pact::SomethingLike.new(1)
      end
    end

    describe "#each_like" do
      it "creates a Pact::ArrayLike" do
        expect(each_like(1)).to eq Pact::ArrayLike.new(1)
        expect(each_like(1, min: 2)).to eq Pact::ArrayLike.new(1, min: 2)
      end
    end

    describe "#like_uuid" do
      let(:uuid) { '11111111-2222-3333-4444-000000000000' }

      it "creates a Pact::Term with UUID matcher" do
        expect(like_uuid(uuid)).to eq Pact::Term.new(
          generate: uuid,
          matcher: /^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$/
        )
      end
    end

    describe "#like_datetime" do
      let(:datetime) { '2015-08-06T16:53:10+01:00' }

      it "creates a Pact::Term with DateTime matcher" do
        expect(like_datetime(datetime)).to eq Pact::Term.new(
          generate: datetime,
          matcher: /^\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z)$/
        )
      end
    end

    describe "#like_datetime_with_milliseconds" do
      let(:datetime) { '2015-08-06T16:53:10.123+01:00' }

      it "creates a Pact::Term with DateTime and Millisecond precision matcher" do
        expect(like_datetime_with_milliseconds(datetime)).to eq Pact::Term.new(
          generate: datetime,
          matcher: /^\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d{3}([+-][0-2]\d:[0-5]\d|Z)$/
        )
      end
    end

    describe "#like_date" do
      let(:date) { '2015-08-06' }

      it "creates a Pact::Term with Date matcher" do
        expect(like_date(date)).to eq Pact::Term.new(
          generate: date,
          matcher: /^\d{4}-[01]\d-[0-3]\d$/
        )
      end

      describe "#like_datetime_rfc822" do
        context "Day is Tue" do
          let(:datetime) { 'Tue, 04 Apr 2017 19:03:19 +0000' }
          it "creates a Pact::Term with a rfc822 matcher" do
            expect(like_datetime_rfc822(datetime)).to eq Pact::Term.new(
              generate: datetime,
              matcher: /(?x)(Mon|Tue|Wed|Thu|Fri|Sat|Sun),
                        \s\d{2}\s
                        (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)
                        \s\d{4}\s\d{2}:\d{2}:\d{2}\s(\+|-)\d{4}/)
          end
        end

        context "Day is Sun" do
          let(:datetime) { 'Sun, 09 Apr 2017 19:03:19 +0000' }
          it "creates a Pact::Term with a rfc822 matcher" do
            expect(like_datetime_rfc822(datetime)).to eq Pact::Term.new(
              generate: datetime,
              matcher: /(?x)(Mon|Tue|Wed|Thu|Fri|Sat|Sun),
                        \s\d{2}\s
                        (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)
                        \s\d{4}\s\d{2}:\d{2}:\d{2}\s(\+|-)\d{4}/)
          end
        end

        context "Month is Jan" do
          let(:datetime) { 'Mon, 02 Jan 2017 19:03:19 +0000' }
          it "creates a Pact::Term with a rfc822 matcher" do
            expect(like_datetime_rfc822(datetime)).to eq Pact::Term.new(
              generate: datetime,
              matcher: /(?x)(Mon|Tue|Wed|Thu|Fri|Sat|Sun),
                        \s\d{2}\s
                        (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)
                        \s\d{4}\s\d{2}:\d{2}:\d{2}\s(\+|-)\d{4}/)
          end
        end

        context "Negative Offset" do
          let(:datetime) { 'Mon, 31 Oct 2016 15:21:41 -0400' }
          it "creates a Pact::Term with a rfc822 matcher" do
            expect(like_datetime_rfc822(datetime)).to eq Pact::Term.new(
              generate: datetime,
              matcher: /(?x)(Mon|Tue|Wed|Thu|Fri|Sat|Sun),
                        \s\d{2}\s
                        (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)
                        \s\d{4}\s\d{2}:\d{2}:\d{2}\s(\+|-)\d{4}/)
          end
        end

      end
    end
  end
end
