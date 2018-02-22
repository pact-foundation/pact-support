require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:spec_with_message_class) do | task |
  task.pattern = "spec/lib/pact/consumer_contract/message_spec_with_message_class.rb"
end

RSpec::Core::RakeTask.new(:spec_with_message_module) do | task |
  task.pattern = "spec/lib/pact/consumer_contract/message_spec_with_message_module.rb"
end

task :set_active_support_on do
  ENV["LOAD_ACTIVE_SUPPORT"] = 'true'
end

desc "This is to ensure that the gem still works even when active support JSON is loaded."
task :spec_with_active_support => [:set_active_support_on] do
  Rake::Task['spec'].execute
end

task :default => [:spec, :spec_with_active_support, :spec_with_message_class, :spec_with_message_module]
