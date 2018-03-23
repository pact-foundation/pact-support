module Pact
  class SpecificationVersion < Gem::Version

    NIL_VERSION = SpecificationVersion.new('')

    def major
      segments.first
    end
  end
end
