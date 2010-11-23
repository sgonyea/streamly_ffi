# encoding: UTF-8
require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe StreamlyFFI::Request do

  before(:all) do
    @response = "Hello, brian".strip
  end

  describe "HEAD" do
    before :each do
      @response = StreamlyFFI.head('http://localhost/')
    end

    describe "basic" do
      it "should perform a basic request" do
        @response.should_not be_nil
      end

      it "should contain common header data" do
        (@response =~ /HTTP.+200 OK/).should_not  be_nil
        (@response =~ /Date/).should_not          be_nil
        (@response =~ /Content-Type/).should_not  be_nil
        (@response =~ /Hullo/).should             be_nil
      end
    end # describe "basic"

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
    end # describe "streaming"
  end # describe "HEAD"

  describe "GET" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.get('localhost:4567/?name=brian')
        resp.should eql(@response)
      end
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
    end
  end

  describe "POST" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.post('localhost:4567', 'name=brian')
        resp.should eql(@response)
      end
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
    end
  end

  describe "PUT" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.put('localhost:4567', 'name=brian')
        resp.should eql(@response)
      end
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
    end
  end

  describe "DELETE" do
    describe "basic" do
      it "should perform a basic request" do
        resp = StreamlyFFI.delete('localhost:4567/?name=brian').should eql(@response)
      end
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
    end
  end
end