require 'rake'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'rspec-system/rake_task'

task :default => :spec

task :install => :build do
  puts `puppet module install -f pkg/puppetlabs-gce_compute-*.tar.gz`
end

desc "Run spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_unit_standalone) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/unit/**/*_spec.rb'
end

desc "Run spec tests in a clean fixtures directory"
task :spec_unit do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_unit_standalone].invoke
  Rake::Task[:spec_clean].invoke
end

desc "Run spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_integration_standalone) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/integration/**/*_spec.rb'
end

desc "Run spec tests in a clean fixtures directory"
task :spec_integration do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_integration_standalone].invoke
  Rake::Task[:spec_clean].invoke
end
