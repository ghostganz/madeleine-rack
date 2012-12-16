# -*- coding: utf-8 -*-

require 'madeleine/rack/input_proxy'
require 'stringio'

describe Madeleine::Rack::InputProxy do

  #
  # From the Rack specification:
  #
  # The input stream is an IO-like object which contains the raw HTTP POST data. When applicable, its external encoding
  # must be “ASCII-8BIT” and it must be opened in binary mode, for Ruby 1.9 compatibility. The input stream must respond
  # to gets, each, read and rewind.
  #
  #    gets must be called without arguments and return a string, or nil on EOF.
  #    read behaves like IO#read. Its signature is read([length, [buffer]]). If given, length must be an non-negative
  #       Integer (>= 0) or nil, and buffer must be a String and may not be nil. If length is given and not nil, then
  #       this method reads at most length bytes from the input stream. If length is not given or nil, then this method
  #       reads all data until EOF. When EOF is reached, this method returns nil if length is given and not nil, or “”
  #       if length is not given or is nil. If buffer is given, then the read data will be placed into buffer instead of
  #       a newly created String object.
  #    each must be called without arguments and only yield Strings.
  #    rewind must be called without arguments. It rewinds the input stream back to the beginning. It must not raise
  #      Errno::ESPIPE: that is, it may not be a pipe or a socket. Therefore, handler developers must buffer the input
  #      data into some rewindable object if the underlying input stream is not rewindable.
  #    close must never be called on the input stream.
  #

  before do
    data = "hey\nho\nlet's\ngo".encode('ASCII-8BIT')
    @original_input = StringIO.new(data) # StringIO is not marshallable
    @input = Madeleine::Rack::InputProxy.new(@original_input)
  end

  # TODO don't repeat same code in both contexts
  context "when used during normal operations" do

    it "can gets()" do
      6.times.collect { @input.gets }.should == ["hey\n", "ho\n", "let's\n", "go", nil, nil]
    end

    # TODO only run this test on 1.9
    it "has an external encoding of ASCII-8BIT" do
      @input.external_encoding.should == Encoding.find('ASCII-8BIT')
    end

    it "is in binary mode" do
      @input.binmode?.should == true
    end
  end

  context "when used during recovery" do
    before do
      @input = Marshal.load(Marshal.dump(@input))
    end

    it "can gets()" do
      6.times.collect { @input.gets }.should == ["hey\n", "ho\n", "let's\n", "go", nil, nil]
    end

    # TODO only run this test on 1.9
    it "has an external encoding of ASCII-8BIT" do
      @input.external_encoding.should == Encoding.find('ASCII-8BIT')
    end

    it "is in binary mode" do
      @input.binmode?.should ==true
    end

    it "leaves the original input rewound after using it" do
      @original_input.pos.should == 0
    end
  end
end
