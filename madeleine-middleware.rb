# -*- coding: utf-8 -*-
require 'madeleine'
require 'stringio'

class Madeleine::Middleware
  def self.global_app
    @@global_app
  end

  def self.global_app=(app)
    @@global_app = app
  end

  class Transaction

    def initialize(env)
      @env = env
    end

    def execute(system)
      puts "execute(#{system})"
      env = @env.dup
      env['MADELEINE_SYSTEM'] = system
      Madeleine::Middleware.global_app.call(env)
    end

    def marshal_dump
      result = @env.dup
      input = @env['rack.input']
      data = input.read
      input.rewind
      result['rack.input'] = data
      # TODO:
      result.delete 'rack.errors'
#      result.delete "action_dispatch.routes"
#      result.delete "action_dispatch.logger"
#      result.delete "action_dispatch.backtrace_cleaner"

      result
    end

    def marshal_load(obj)
      @env = obj
      @env['rack.input'] = StringIO.new(obj['rack.input'])
    end
  end

  def initialize(app)
    Madeleine::Middleware.global_app = app
    @madeleine = SnapshotMadeleine.new("some_storage") {
      Hash.new
    }
  end

  def call(env)
    p env
    transaction = Transaction.new(env)
    @madeleine.execute_command(transaction)
  end
end
