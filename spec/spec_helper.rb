dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, '../lib')

RSpec.configure do |config|
    config.mock_framework = :mocha
end
