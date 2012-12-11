# -*- coding: utf-8 -*-
require 'madeleine'
require 'stringio'

module Madeleine
  module Rack
  end
end

class Madeleine::Rack::Middleware
  def self.global_app
    @@global_app
  end

  def self.global_app=(app)
    @@global_app = app
  end

  class LoggedRequest

    def initialize(env)
      @env = env
    end

    def execute(system)
      puts "execute(#{system})"
      env = @env.dup
      Thread.current[:_madeleine_system] = system
      Madeleine::Rack::Middleware.global_app.call(env)
    end

    def marshal_dump
      result = @env.dup
      input = @env['rack.input']
      data = input.read
      input.rewind
      result['rack.input'] = data
      result.delete 'rack.errors'
      result
    end

    def marshal_load(obj)
      @env = obj
      @env['rack.input'] = StringIO.new(obj['rack.input'])
      @env['rack.errors'] = StringIO.new
    end
  end

  def initialize(app)
    Madeleine::Rack::Middleware.global_app = app
    @madeleine = SnapshotMadeleine.new("some_storage") {
      Hash.new
    }
  end

  def call(env)
    transaction = LoggedRequest.new(env)
    @madeleine.execute_command(transaction)
  end
end
