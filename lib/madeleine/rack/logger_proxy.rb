require 'madeleine/rack/env_proxy'

module Madeleine
  module Rack
    class LoggerProxy
      extend EnvProxy

      def self.key
        'rack.logger'
      end

      def initialize(logger)
        @logger = logger
      end

      def marshal_dump
        # Nothing to store, particularly not the real logger
        nil
      end

      def marshal_load(arg)
        # No-op
      end

      # The Rack specification says we should have these for 'rack.logger':
      # info(message, &block)
      # debug(message, &block)
      # warn(message, &block)
      # error(message, &block)
      # fatal(message, &block)

      def info(message, &block)
        @logger.info(message, &block) if @logger
      end

      def debug(message, &block)
        @logger.debug(message, &block) if @logger
      end

      def warn(message, &block)
        @logger.warn(message, &block) if @logger
      end

      def error(message, &block)
        @logger.error(message, &block) if @logger
      end

      def fatal(message, &block)
        @logger.fatal(message, &block) if @logger
      end
    end
  end
end
