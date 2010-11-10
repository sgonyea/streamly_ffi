# encoding: UTF-8
require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe StreamlyFFI::Request do

  before(:all) do
    @response = "Hello, brian".strip
  end

  describe "HEAD" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.head('localhost:4567')
        resp.should_not be_nil
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.head('localhost:4567').encoding.should eql(Encoding.find('utf-8'))
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.head('localhost:4567').encoding.should eql(Encoding.default_internal)
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.head('localhost:4567').encoding.should eql(Encoding.default_internal)
        end
      end
=end
    end

    describe "streaming" do
      it "should perform a basic request and stream header chunks to the caller" do
        streamed_response = ""
        resp = StreamlyFFI.head('localhost:4567') do |chunk|
          chunk.should_not be_empty
          streamed_response << chunk
        end
        resp.should be_nil
        streamed_response.should_not be_nil
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.head('localhost:4567') do |chunk|
            chunk.encoding.should eql(Encoding.find('utf-8'))
          end
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.head('localhost:4567') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.head('localhost:4567') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
        end
      end
=end
    end
  end

  describe "GET" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.get('localhost:4567/?name=brian')
        resp.should eql(@response)
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.get('localhost:4567').encoding.should eql(Encoding.find('utf-8'))
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.get('localhost:4567').encoding.should eql(Encoding.default_internal)
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.get('localhost:4567').encoding.should eql(Encoding.default_internal)
        end
      end
=end
    end

    describe "streaming" do
      it "should perform a basic request and stream the response to the caller" do
        streamed_response = ''
        resp = StreamlyFFI.get('localhost:4567/?name=brian') do |chunk|
          chunk.should_not be_empty
          streamed_response << chunk
        end
        resp.should be_nil
        streamed_response.should eql(@response)
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.get('localhost:4567') do |chunk|
            chunk.encoding.should eql(Encoding.find('utf-8'))
          end
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.get('localhost:4567') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.get('localhost:4567') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
        end
      end
=end
    end
  end

  describe "POST" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.post('localhost:4567', 'name=brian')
        resp.should eql(@response)
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.post('localhost:4567', 'name=brian').encoding.should eql(Encoding.find('utf-8'))
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.post('localhost:4567', 'name=brian').encoding.should eql(Encoding.default_internal)
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.post('localhost:4567', 'name=brian').encoding.should eql(Encoding.default_internal)
        end
      end
=end
    end

    describe "streaming" do
      it "should perform a basic request and stream the response to the caller" do
        streamed_response = ''
        resp = StreamlyFFI.post('localhost:4567', 'name=brian') do |chunk|
          chunk.should_not be_empty
          streamed_response << chunk
        end
        resp.should be_nil
        streamed_response.should eql(@response)
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.post('localhost:4567', 'name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.find('utf-8'))
          end
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.post('localhost:4567', 'name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.post('localhost:4567', 'name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
        end
      end
=end
    end
  end

  describe "PUT" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.put('localhost:4567', 'name=brian')
        resp.should eql(@response)
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.put('localhost:4567', 'name=brian').encoding.should eql(Encoding.find('utf-8'))
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.put('localhost:4567', 'name=brian').encoding.should eql(Encoding.default_internal)
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.put('localhost:4567', 'name=brian').encoding.should eql(Encoding.default_internal)
        end
      end
=end
    end

    describe "streaming" do
      it "should perform a basic request and stream the response to the caller" do
        streamed_response = ''
        resp = StreamlyFFI.put('localhost:4567', 'name=brian') do |chunk|
          chunk.should_not be_empty
          streamed_response << chunk
        end
        resp.should be_nil
        streamed_response.should eql(@response)
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.put('localhost:4567', 'name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.find('utf-8'))
          end
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.put('localhost:4567', 'name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.put('localhost:4567', 'name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
        end
      end
=end
    end
  end

  describe "DELETE" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.delete('localhost:4567/?name=brian').should eql(@response)
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.delete('localhost:4567/?name=brian').encoding.should eql(Encoding.find('utf-8'))
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.delete('localhost:4567/?name=brian').encoding.should eql(Encoding.default_internal)
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.delete('localhost:4567/?name=brian').encoding.should eql(Encoding.default_internal)
        end
      end
=end
    end

    describe "streaming" do
      it "should perform a basic request and stream the response to the caller" do
        streamed_response = ''
        resp = StreamlyFFI.delete('localhost:4567/?name=brian') do |chunk|
          chunk.should_not be_empty
          streamed_response << chunk
        end
        resp.should be_nil
        streamed_response.should eql(@response)
      end
=begin
      if RUBY_VERSION =~ /^1.9/
        it "should default to utf-8 if Encoding.default_internal is nil" do
          Encoding.default_internal = nil
          StreamlyFFI.delete('localhost:4567/?name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.find('utf-8'))
          end
        end

        it "should use Encoding.default_internal" do
          Encoding.default_internal = Encoding.find('utf-8')
          StreamlyFFI.delete('localhost:4567/?name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
          Encoding.default_internal = Encoding.find('us-ascii')
          StreamlyFFI.delete('localhost:4567/?name=brian') do |chunk|
            chunk.encoding.should eql(Encoding.default_internal)
          end
        end
      end
=end
    end
  end
end