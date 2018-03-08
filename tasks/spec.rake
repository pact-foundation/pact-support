require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :set_active_support_on do
  ENV["LOAD_ACTIVE_SUPPORT"] = 'true'
end

desc "This is to ensure that the gem still works even when active support JSON is loaded."
task :spec_with_active_support => [:set_active_support_on] do
  Rake::Task['spec'].execute
end

task :default => [:spec, :spec_with_active_support]
