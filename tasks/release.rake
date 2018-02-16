task :generate_changelog do
  require 'pact/support/version'
  ConventionalChangelog::Generator.new.generate! version: "v#{Pact::Support::VERSION}"
end
