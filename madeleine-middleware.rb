# -*- coding: utf-8 -*-
require 'madeleine'

class Madeleine::Middleware
  @@global_app = nil

  class Transaction

    def initialize(app, env)
      @@global_app = app # UGH!
      @env = env
    end

    def execute(system)
      env = @env.dup
      env['MADELEINE_SYSTEM'] = system
      @@global_app.call(env)
    end

    def marshal_dump
      result = @env.dup
      # TODO need to replace these with marshalable things
      result.delete 'rack.input'
      result.delete 'rack.errors'
      result
    end

    def marshal_load(obj)
      @env = obj
    end
  end

  def initialize(app)
    @app = app
    @madeleine = SnapshotMadeleine.new("some_storage") {
      Hash.new
    }
  end

  def call(env)
    transaction = Transaction.new(@app, env)
    @madeleine.execute_command(transaction)
    @app.call(env)
  end
end
