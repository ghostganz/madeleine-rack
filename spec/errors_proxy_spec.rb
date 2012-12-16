# -*- coding: utf-8 -*-

require 'madeleine/rack/errors_proxy'
require 'stringio'

describe Madeleine::Rack::ErrorsProxy do

  # From the Rack specification:
  #
  #The Error Stream
  #
  #The error stream must respond to puts, write and flush.
  #
  #    puts must be called with a single argument that responds to to_s.
  #    write must be called with a single argument that is a String.
  #    flush must be called without arguments and must be called in order to make the error appear for sure.
  #    close must never be called on the error stream.

  before do
    @original_errors = StringIO.new # StringIO is not marshallable
    @errors = Madeleine::Rack::ErrorsProxy.new(@original_errors)
  end

  context "when used during normal operations" do
    it "passes writes along to the real stream" do
      @errors.puts "hello"
      @errors.write "world"
      @errors.flush

      @original_errors.rewind
      @original_errors.read.should == "hello\nworld"
    end
  end

  context "when used during recovery" do
    before do
      @errors = Marshal.load(Marshal.dump(@errors))
    end

    it "simply discards output" do
      @errors.puts "hello"
      @errors.write "world"
      @errors.flush

      @original_errors.rewind
      @original_errors.read.should == ""
    end
  end
end
