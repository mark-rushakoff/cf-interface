$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

require "rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
