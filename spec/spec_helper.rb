require 'rubygems'
require 'bundler/setup'
require 'rails/all'
require 'yaml'

$: << File.dirname(__FILE__) + '/../lib'

require 'optin_parsing'
require 'action_controller'
require 'rspec/rails'

module DummyApplication
  class Application < Rails::Application
    config.secret_token = '*******************************'
    config.logger = Logger.new(File.expand_path('../test.log', __FILE__))
    Rails.logger = config.logger
  end
end
RSpec.configure do |config|

end
