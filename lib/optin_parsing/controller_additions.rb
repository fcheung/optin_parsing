module OptinParsing
  module ControllerAdditions
    extend ActiveSupport::Concern

    included do
      class_attribute :parse_strategies
      self.parse_strategies = {}
      hide_action :decode_formatted_parameters
    end

    module ClassMethods
      # Declares that you want to parse a specific body type, for this controller and its subclasses
      # You can either pass the symbols +:xml+ or +:json+ or an instance of Mime::Type. If you pass
      # a Mime::Type you must also supply a block. The block will be passed the request raw post data
      # and should return a hash of parsed parameter data
      #
      # You can also supply a hash of options containing the keys +:except+ or +:only+ to restrict which
      # actions will be parsed
      #
      #
      # @param [Symbol, Mime::Type] mime_type_or_short_cut
      # @option options [Array,Symbol] :except A list of actions for which parsing should not be enabled
      # @option options [Array,Symbol] :only A list of actions for which parsing should be enabled

      def parses mime_type_or_short_cut, options={}, &block

        case mime_type_or_short_cut
        when Mime::Type
          raise ArgumentError, "You must supply a block when specifying a mime type" unless block
          self.parse_strategies = parse_strategies.merge(mime_type_or_short_cut => [block, normalize_optin_options(options)])
        when :xml
          self.parse_strategies = parse_strategies.merge(Mime::XML => [:xml, normalize_optin_options(options)])
        when :json
          self.parse_strategies = parse_strategies.merge(Mime::JSON => [:json, normalize_optin_options(options)])
        end
      end
      private

      def normalize_optin_options options
        options.each_with_object({}) do |(key,value), options|
          options[key] = Array(value).collect {|action_name| action_name.to_s}
        end
      end
    end

    def process_action(method_name, *args)
      strategy, options = parse_strategies[request.content_mime_type]
      if strategy
        if should_decode_body(options)
          if data = decode_formatted_parameters(strategy)
            params.merge!(data)
            log_parsed(apply_filter_parameters(data))
          end
        end
      end
      super
    end

    private

    def should_decode_body options
      if options[:only]
        options[:only].include?(action_name)
      elsif options[:except]
        !options[:except].include?(action_name)
      else
        true
      end
    end

    def decode_formatted_parameters(strategy)
      case strategy
      when Proc
        strategy.call(request.raw_post)
      when :xml
        data = request.deep_munge(Hash.from_xml(request.body.read) || {})
        request.body.rewind if request.body.respond_to?(:rewind)
        data.with_indifferent_access
      when :json
        data = request.deep_munge ActiveSupport::JSON.decode(request.body.read)
        request.body.rewind if request.body.respond_to?(:rewind)
        data = {:_json => data} unless data.is_a?(Hash)
        data.with_indifferent_access
      else
        false
      end
    end

    def log_parsed(data)
      Rails.logger.info "Parsed #{request.content_mime_type}: #{data.inspect}"
    end

    def apply_filter_parameters(data)
      parameter_filter = ActionDispatch::Http::ParameterFilter.new(Rails.configuration.filter_parameters)
      parameter_filter.filter(data)
    end
  end
end
