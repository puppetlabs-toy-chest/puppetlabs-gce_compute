# $ ruby --version
# ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-linux]
# $ gem list
# diff-lcs (1.2.4)
# metaclass (0.0.1)
# mocha (0.13.3)
# rake (10.0.4)
# rspec (2.13.0)
# rspec-core (2.13.1)
# rspec-expectations (2.13.0)
# rspec-mocks (2.13.1)

require 'rake'
require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '--backtrace'
  t.rspec_opts << ' --color'
  t.rspec_opts << ' --fail-fast'
  t.verbose = true
end
