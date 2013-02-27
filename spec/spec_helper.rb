require 'rubygems'
require 'bundler/setup'

$: << File.dirname(__FILE__) + '/../lib'

require 'optin_parsing'
require 'action_controller'
require 'rspec/rails'

module DummyApplication
  class Application < Rails::Application
  end
end
RSpec.configure do |config|
  
end