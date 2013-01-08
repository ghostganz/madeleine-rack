require 'madeleine/rack/env_proxy'
require 'delegate'

module Madeleine
  module Rack
    class InputProxy < Delegator
      extend EnvProxy

      def self.key
        'rack.input'
      end

      def initialize(input)
        @input = input
      end

      def __getobj__
        @input
      end

      def marshal_dump
        result = @input.read
        @input.rewind
        result
      end

      def marshal_load(data)
        @input = StringIO.new(data)
      end

      def binmode?
        # TODO ensure this is true for marshalled data too
        true
      end
    end
  end
end
