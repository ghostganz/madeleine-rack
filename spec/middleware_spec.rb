# -*- coding: utf-8 -*-

require 'madeleine/rack'

describe Madeleine::Rack::Middleware do

  context "Executing a request" do
    before do
      @app = stub('The Application')
      @madeleine = stub('The Madeleine')
      Madeleine::SnapshotMadeleine.stub(:new).with('the_storage_dir').and_return(@madeleine)
      @middleware = Madeleine::Rack::Middleware.new(@app, 'the_storage_dir')
    end

    it "puts a command into Madeleine" do
      @madeleine.should_receive(:execute_command).once

      @middleware.call({})
    end

    context "With a Madeleine that executes the command" do
      before do
        @system = {'foo' => 'bar'}
        @madeleine.stub(:execute_command) {|command|
          command.execute(@system)
        }
      end

      it "calls the app with the env" do
        env = {'some_env_param' => 'some_env_value'}
        @app.should_receive(:call) {|an_env|
          an_env.should == env
        }

        @middleware.call(env)
      end

      it "passes the persistent system to the app" do
        @app.should_receive(:call) {|_|
          Thread.current[:_madeleine_system].should == @system
        }

        @middleware.call({})
      end
    end
  end

  # TODO test that it creates an empty system
  # TODO test that it would restore the system's state, if the Madeleine replays the commands
end