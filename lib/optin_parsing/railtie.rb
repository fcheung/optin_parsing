require "optin_parsing"
require "rails"

module OptinParsing
  # = OptinParsing Railtie
  class Railtie < Rails::Railtie

    initializer "optinparsing.inject_modules" do |app|
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send :include, OptinParsing::ControllerAdditions
      end
    end

    initializer "optinparsing.remove_default_parsers" do |app|
      config.app_middleware.delete '::ActionDispatch::ParamsParser'
    end
  end
end
