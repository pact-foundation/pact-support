require 'spec_helper'
require 'byebug'

module Pact
  describe ProviderParam do

    describe 'initialize' do
      let(:fill_string) { 'some/:variable/here'}
      subject {ProviderParam.new(generate: generate, fill_string: fill_string)}
      context "with generate and a fill string" do
        context "and fill string matches generate" do
          let(:generate) { 'some/url/here'}
          it 'should say that generate is valid' do
            expect(subject).to be_instance_of(Pact::ProviderParam)
          end
          it 'should find fillable parameters' do
            expect(subject.fillable_params).to eq([':variable'])
          end
        end
        context "and fill string doesn't match generate" do
          let(:generate) { 'incorrect/url/here'}
          it 'should throw an error' do
            expect{subject}.to raise_error /not a valid substitute/
          end
        end
        context "and fill string has too many parameters" do
          let(:generate) {'some/url/here'}
          it 'should throw an error' do
            expect{ProviderParam.new(generate: generate, fill_string: 'some/:url/:here')}.to raise_error /not a valid substitute/
          end
        end
      end
    end
  end
end
