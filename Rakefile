require 'rake'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'rspec-system/rake_task'

task :default => :spec

task :install => :build do
  puts `puppet module install -f pkg/puppetlabs-gce_compute-*.tar.gz`
end
