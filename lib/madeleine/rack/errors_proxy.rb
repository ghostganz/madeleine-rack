require 'madeleine/rack/env_proxy'

module Madeleine
  module Rack
    class ErrorsProxy
      extend EnvProxy

      def self.key
        'rack.errors'
      end

      def initialize(errors)
        @errors = errors
      end

      def marshal_dump
        # Not holding on to @errors, obviously
      end

      def marshal_load(_)
        # Letting @errors remain nil
      end

      def puts(s)
        @errors.puts(s) if @errors
      end

      def write(s)
        @errors.write(s) if @errors
      end

      def flush
        @errors.flush if @errors
      end
    end
  end
end
