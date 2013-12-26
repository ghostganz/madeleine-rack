# -*- coding: utf-8 -*-

require 'madeleine/rack'

describe Madeleine::Rack::Middleware do

  context "Executing a request" do
    before do
      @app = double('The Application')
      @madeleine = double('The Madeleine')
      Madeleine::SnapshotMadeleine.stub(:new).and_return(@madeleine)
      @middleware = Madeleine::Rack::Middleware.new(@app, 'the_storage_dir')
    end

    it "puts a command into Madeleine for execution" do
      @madeleine.should_receive(:execute_command).once

      @middleware.call({})
    end

    context "When it's a GET or HEAD request" do
      it "puts a command into Madeleine for querying" do
        @madeleine.should_receive(:execute_query).once

        @middleware.call({'REQUEST_METHOD' => 'GET'})
      end
    end

    context "With a Madeleine that executes the command" do
      before do
        @system = {'foo' => 'bar'}
        @madeleine.stub(:execute_command) {|command|
          command.execute(@system, @app)
        }
      end

      it "calls the app with the env" do
        env = {'some_env_param' => 'some_env_value'}
        @app.should_receive(:call) {|an_env|
          an_env.should include(env)
        }

        @middleware.call(env)
      end

      it "passes the persistent system to the app as part of the env" do
        @app.should_receive(:call) {|env|
          env['madeleine.system'].should == @system
        }

        @middleware.call({})
      end
    end
  end

  context "Starting up" do

    it "initializes the Madeleine with an empty hash as the system" do
      app = double('The Application')
      Madeleine::SnapshotMadeleine.should_receive(:new) do |dir, &block|
        dir.should == 'the_storage_dir'
        block.yield.should == {}
      end

      Madeleine::Rack::Middleware.new(app, 'the_storage_dir')
    end
  end

  # TODO test that it would restore the system's state, if the Madeleine replays the commands
end
