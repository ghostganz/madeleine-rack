module Madeleine
  module Rack
    module EnvProxy
      def key
        raise NotImplementedError
      end

      def add(env)
        if env[key]
          env[key] = new(env[key])
        end
      end
    end
  end
end
