task :generate_changelog do
  require 'pact/support/version'
  require 'conventional_changelog'
  ConventionalChangelog::Generator.new.generate! version: "v#{Pact::Support::VERSION}"
end
