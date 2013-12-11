# -*- coding: utf-8 -*-
require 'madeleine'
require 'stringio'
require 'madeleine/rack/logger_proxy'
require 'madeleine/rack/input_proxy'
require 'madeleine/rack/errors_proxy'

module Madeleine
  module Rack
    class Middleware

      class LoggedRequest

        def initialize(env)
          @env = env.dup

          Madeleine::Rack::LoggerProxy.add_proxy(@env)
          Madeleine::Rack::InputProxy.add_proxy(@env)
          Madeleine::Rack::ErrorsProxy.add_proxy(@env)
        end

        def execute(system, app)
          puts "execute(#{system}, #{app})"

          # Put the system where we can find it from
          # within a Rails controller etc.
          Thread.current[:_madeleine_system] = system

          # Continue to the app
          status, headers, body = app.call(@env)

          # Some later middlewares, Rack::Lock in particular,
          # do cleanup and release of locks on closure of the
          # input stream. We have to make sure that happens
          # during command replay too, when the web server
          # doesn't do it for us.
          body.close if body.respond_to? :close

          [status, headers, body]
        end

        def marshal_dump
          result = @env.dup
          result.delete 'async.callback' # Used by Thin
          result
        end

        def marshal_load(obj)
          @env = obj
        end
      end

      def initialize(app, storage_directory, &system_seed_block)
        system_seed_block ||= lambda { Hash.new }
        @madeleine = Madeleine::SnapshotMadeleine.new(storage_directory, execution_context: app, &system_seed_block)
      end

      def call(env)
        transaction = LoggedRequest.new(env)

        if read_only?(env)
          @madeleine.execute_query(transaction)
        else
          @madeleine.execute_command(transaction)
        end
      end

      private

      READ_ONLY_METHODS = ['GET', 'HEAD', 'OPTIONS', 'TRACE']

      def read_only?(env)
        READ_ONLY_METHODS.include? env['REQUEST_METHOD']
      end
    end
  end
end
