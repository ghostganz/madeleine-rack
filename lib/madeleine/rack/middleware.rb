# -*- coding: utf-8 -*-
require 'madeleine'
require 'stringio'
require 'madeleine/rack/logger_proxy'
require 'madeleine/rack/input_proxy'
require 'madeleine/rack/errors_proxy'

module Madeleine
  module Rack
    class Middleware
      def self.global_app
        @@global_app
      end

      def self.global_app=(app)
        @@global_app = app
      end

      class LoggedRequest

        def initialize(env)
          @env = env.dup

          Madeleine::Rack::LoggerProxy.add(@env)
          Madeleine::Rack::InputProxy.add(@env)
          Madeleine::Rack::ErrorsProxy.add(@env)
        end

        def execute(system)
          puts "execute(#{system})"

          # Put the system where we can find it from
          # within a Rails controller etc.
          Thread.current[:_madeleine_system] = system

          # Continue to the app
          status, headers, body = Madeleine::Rack::Middleware.global_app.call(@env)

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

      def initialize(app, storage_directory)
        Madeleine::Rack::Middleware.global_app = app
        @madeleine = Madeleine::SnapshotMadeleine.new(storage_directory) {
          Hash.new
        }
      end

      def call(env)
        transaction = LoggedRequest.new(env)
        @madeleine.execute_command(transaction)
      end
    end
  end
end
