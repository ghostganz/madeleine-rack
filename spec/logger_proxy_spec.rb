
require 'madeleine/rack/logger_proxy'

describe Madeleine::Rack::LoggerProxy do
  before do
    @original_logger = double
    @original_logger.stub(:marshal_dump).and_raise("Don't attempt to marshal the logger!")
    @logger = Madeleine::Rack::LoggerProxy.new(@original_logger)
  end

  context "when used during normal operations" do

    it "logs to the original logger" do
      block = lambda {}

      @original_logger.should_receive(:info).with("info message").and_yield
      @original_logger.should_receive(:debug).with("debug message").and_yield
      @original_logger.should_receive(:warn).with("warn message").and_yield
      @original_logger.should_receive(:error).with("error message").and_yield
      @original_logger.should_receive(:fatal).with("fatal message").and_yield

      @logger.info("info message", &block)
      @logger.debug("debug message", &block)
      @logger.warn("warn message", &block)
      @logger.error("error message", &block)
      @logger.fatal("fatal message", &block)
    end
  end

  context "when used during recovery" do
    before do
      @logger = Marshal.load(Marshal.dump(@logger))
    end

    it "silently ignores logged things" do
      block = lambda {}

      @logger.info("info message", &block)
      @logger.debug("debug message", &block)
      @logger.warn("warn message", &block)
      @logger.error("error message", &block)
      @logger.fatal("fatal message", &block)

      # Nothing should have happened
    end
  end
end
