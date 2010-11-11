require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe StreamlyFFI::PersistentRequest do
  context 'escape method' do
    before(:all) do
      @connection = StreamlyFFI.connect
    end

    it 'should escape properly' do
      @connection.escape('+').should == '%2B'
      @connection.escape('This is a test').should == 'This%20is%20a%20test'
      @connection.escape('<>/\\').should == '%3C%3E%2F%5C'
      @connection.escape('"').should == '%22'
      @connection.escape(':').should == '%3A'
    end

    it 'should escape brackets' do
      @connection.escape('{').should == '%7B'
      @connection.escape('}').should == '%7D'
    end

    it 'should escape exclamation marks!' do
      @connection.escape('!').should == '%21'
    end
  end
end