require 'rake'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

task :default => :spec

PuppetLint.configuration.send('disable_80chars')

task :install => :build do
  puts `puppet module install -f pkg/puppetlabs-gce_compute-*.tar.gz`
end

desc "Run unit spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_unit_standalone) do |t|
  t.rspec_opts = ['--color', '--order', 'rand']
  t.verbose = false
  t.pattern = 'spec/unit/**/*_spec.rb'
end

desc "Run integration spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_integration_standalone) do |t|
  t.rspec_opts = ['--color', '--order', 'rand']
  t.verbose = false
  t.pattern = 'spec/integration/**/*_spec.rb'
end
task :spec_integration_standalone => :install

task(:spec_standalone).clear
desc "Run unit spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_standalone) do |t|
  t.rspec_opts = ['--color', '--order', 'rand']
  t.verbose = false
  t.pattern = 'spec/{unit,integration}/**/*_spec.rb'
end
task :spec_standalone => :install

namespace :spec do
  desc "Run unit spec tests in a clean fixtures directory"
  task :unit => [:spec_prep, :spec_unit_standalone, :spec_clean]
  desc "Run integration spec tests in a clean fixtures directory"
  task :integration => [:spec_prep, :spec_integration_standalone, :spec_clean]

  namespace :integration do
    desc "Cleanup after failed integration specs"
    task :clean do
      puts `ls examples/**/*down.pp | xargs -n 1 puppet apply`
    end
  end
end

desc "Run lint and spec tests and check metadata format"
task :test => [
  :syntax,
  :lint,
  :metadata,
  :spec
]
