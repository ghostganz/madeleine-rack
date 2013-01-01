module Madeleine
  module Rack
    class EnvProxy
      def self.key
        raise NotImplementedError
      end

      def self.add(env)
        if env[key]
          env[key] = new(env[key])
        end
      end
    end
  end
end
