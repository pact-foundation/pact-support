require 'fakefs/spec_helpers'
require 'pact/support'
require 'webmock/rspec'
require 'support/factories'
require 'support/spec_support'

WebMock.disable_net_connect!(allow_localhost: true)

require './spec/support/active_support_if_configured'

RSpec.configure do | config |
  config.include(FakeFS::SpecHelpers, :fakefs => true)

  config.include Pact::SpecSupport
  if config.respond_to?(:example_status_persistence_file_path=)
    config.example_status_persistence_file_path = "./spec/examples.txt"
  end
end
