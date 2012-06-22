# -*- coding: utf-8 -*-
require 'madeleine'

class Madeleine::Middleware
  @@global_app = nil

  class Transaction
    # TODO @app ska vara transient

    def initialize(app, env)
      @app = app
      @@global_app = app # UGH!
      @env = env
    end

    def execute(system)
      env = @env.dup
      env['MADELEINE_SYSTEM'] = system
      @app.call(env)
    end
  end

  def initialize(app)
    @app = app
    @madeleine = SnapshotMadeleine.new("some_storage") {
      Hash.new
    }
  end

  def call(env)
    Transaction.new(@app, env)
    @app.call(env)
  end
end
