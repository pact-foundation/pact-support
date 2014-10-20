require 'spec_helper'
require 'pact/configuration'

module Pact

  describe Configuration do

    subject { Configuration.default_configuration }

    describe "#color_enabled" do

      it "sets color_enabled to be true by default" do
        expect(subject.color_enabled).to be true
      end

      it "allows configuration of colour_enabled" do
        subject.color_enabled = false
        expect(subject.color_enabled).to be false
      end

    end

  end
end
