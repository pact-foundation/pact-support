require 'pact/rspec'

module Pact
  module SpecSupport

    extend self

    def load_fixture name
      File.read(File.join("./spec/fixtures", name))
    end

    def load_json_fixture name
      require 'json'
      JSON.parse(load_fixture(name))
    end

    def remove_ansicolor string
      string.gsub(/\e\[(\d+)m/, '')
    end

    Pact::RSpec.with_rspec_2 do

      def instance_double *args
        double(*args)
      end

    end
  end
end