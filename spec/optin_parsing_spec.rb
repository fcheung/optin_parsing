require 'spec_helper'

describe 'optin_parsing controller with controller additions included', :type => :controller do
  include Rails.application.routes.url_helpers
  module Actions
    def index
      @parsed_params = params.except(:controller, :action)
      head :ok
    end

    def new
      @parsed_params = params.except(:controller, :action)
      head :ok
    end

    def _routes
      @routes
    end
  end


  def json
    '{"test": "value"}'
  end

  def xml
    '<?xml version="1.0" encoding="UTF-8"?><test>value</test>'
  end

  context 'when the module is included' do
    def self.preconfigured_controller(&block)
      controller(ActionController::Base) do
        include OptinParsing::ControllerAdditions
        include Actions
        instance_eval(&block)
      end
    end

    context 'parsing is not enabled' do
      preconfigured_controller {}

      it { should_not parse_parameters.of_type(Mime::JSON).for_action(:index).with_body(json) }
      it { should_not parse_parameters.of_type(Mime::XML).for_action(:index).with_body(xml) }
    end

    context 'parsing of xml is enabled' do
      context 'unconditionally' do
        preconfigured_controller do
          parses :xml
        end

        it { should_not parse_parameters.of_type(Mime::JSON).for_action(:index).with_body(json) }
        it { should parse_parameters.of_type(Mime::XML).for_action(:index).with_body(xml) }
      end
    end

    context 'parsing of a custom type is enabled' do
      preconfigured_controller do
        parses Mime::YAML do |body|
          YAML.load(body)
        end
      end
      it { should parse_parameters.of_type(Mime::YAML).for_action(:index).with_body({'test' => 'value'}.to_yaml) }
    end

    context 'parsing of json is enabled' do
      context 'unconditionally' do
        preconfigured_controller do
          parses :json
        end

        it 'logs parsed parameters honouring filter_parameters config' do
          request.env['RAW_POST_DATA'] = json
          request.env['CONTENT_TYPE']  = Mime::JSON.to_s
          Rails.configuration.filter_parameters = [:test]

          controller.should_receive(:log_parsed).with({'test' => '[FILTERED]'})

          put :index
        end

        it { should parse_parameters.of_type(Mime::JSON).for_action(:index).with_body(json) }
        it { should_not parse_parameters.of_type(Mime::XML).for_action(:index).with_body(xml) }
      end

      context 'an only option is specified' do
        preconfigured_controller do
          parses :json, :only => :index
        end

        context 'the action is contained in the list' do
          it { should parse_parameters.of_type(Mime::JSON).for_action(:index).with_body(json) }
        end

        context 'the action is not contained in the list' do
          it { should_not parse_parameters.of_type(Mime::JSON).for_action(:new).with_body(json) }
        end
      end

      context 'an except option is specified' do
        preconfigured_controller do
          parses :json, :except => :index
        end

        context 'the action is contained in the list' do
          it { should_not parse_parameters.of_type(Mime::JSON).for_action(:index).with_body(json) }
        end

        context 'the action is not contained in the list' do
          it { should parse_parameters.of_type(Mime::JSON).for_action(:new).with_body(json) }
        end
      end
    end
  end
end


RSpec::Matchers.define :parse_parameters do |y|

  chain :of_type do |mime_type|
    @mime_type = mime_type
  end

  chain :for_action do |action_name|
    @action_name = action_name
  end

  chain :with_body do |body|
    @body = body
  end

  match do
    @expected = {'test' => 'value'}
    request.env['RAW_POST_DATA'] = @body
    request.env['CONTENT_TYPE'] = @mime_type.to_s
    put @action_name.to_sym
    @actual = assigns(:parsed_params)
    @actual == @expected
  end

  failure_message_for_should do
    "Expected parameters #{@expected} got #{@actual}"
  end
end
