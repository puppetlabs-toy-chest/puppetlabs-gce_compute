source "http://rubygems.org"

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['~> 3.7']
end

gem "rake"
gem "puppet", puppetversion
gem "puppet-lint"
gem "metadata-json-lint"
gem "rspec-puppet"
gem "puppetlabs_spec_helper"
gem "puppet-syntax"
gem "diff-lcs"
gem "metaclass"
gem "rspec"
