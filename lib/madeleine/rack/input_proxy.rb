module Madeleine
  module Rack
    class InputProxy
      def initialize(input)
        @input = input
      end

      def marshal_dump
        result = @input.read
        @input.rewind
        result
      end

      def marshal_load(data)
        @input = StringIO.new(data)
      end

      def gets(*args)
        @input.gets(*args)
      end

      def each(*args, &block)
        @input.each(*args, &block)
      end

      def read(*args)
        @input.read(*args)
      end

      def rewind
        @input.rewind
      end

      def external_encoding
        @input.external_encoding
      end

      def binmode?
        # TODO ensure this is true for marshalled data too
        true
      end
    end
  end
end
