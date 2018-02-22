# I'm not sure whether to make Pact::Message a module or a class at this stage, so making
# the "public interface" to the pact-support library support Pact::Message.new either way

module Pact
  class Message; end
end

load 'pact/consumer_contract/message.rb'
load 'pact/consumer_contract/message/content.rb'

describe Pact::Message::Content do
  describe "new" do
    it "returns an instance of Pact::Message::ConsumerContract::Message::Content" do
      expect(Pact::Message::Content.new('foo')).to be_a(Pact::ConsumerContract::Message::Content)
    end
  end
end

describe Pact::Message do
  describe "new" do
    it "returns an instance of Pact::Message::ConsumerContract::Message" do
      expect(Pact::Message.new).to be_a(Pact::ConsumerContract::Message)
    end
  end
end
