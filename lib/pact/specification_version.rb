module Pact
  class SpecificationVersion < Gem::Version

    NIL_VERSION = Pact::SpecificationVersion.new('')

    def major
      segments.first
    end

    def === other
      major && major == other
    end

    def after? other
      major && other < major
    end
  end
end
