require "ffi"
require "curl_ffi"
require "singleton"

module Streamly
  class Request
    include Singleton

    attr_reader :response_header_handler, :response_body_handler

    CallHandler = Proc.new do |stream, size, nmemb, handler|
      handler.call(stream)
      size * nmemb
    end

    StringHandler = Proc.new do |stream, size, nmemb, handler|
#      _str = (handler.null? ? "" : handler.read_string)
      puts "---stream------------"
      puts stream.inspect
      puts "---_str--------------"
      puts handler.inspect

      handler << stream
#      handler = FFI::MemoryPointer.from_string(handler)

      size * nmemb
    end

    DataHandler = Proc.new do |stream, size, nmemb, handler|
      case handler
      when  String then
        handler << stream
      else
        handler.call(stream)
      end
      size * nmemb
    end

    # @TODO: Argumenting Checking + Error Handling
    def initialize(options={})
      url     = options[:url]
      method  = options[:method]

      # url should be a string that doesn't suck
      # method should be :post, :get, :put, :delete, :head
      # options should contain any of the following keys:
      #   :headers, :response_header_handler, :response_body_handler, :payload (required if method = :post / :put)

#      @response_header_handler  ||= options[:response_header_handler] || FFI::MemoryPointer.from_string("")
#      @response_body_handler    ||= options[:response_body_handler]   || FFI::MemoryPointer.from_string("")

      case method
      when :get     then  connection.setopt :HTTPGET,        1
      when :head    then  connection.setopt :NOBODY,         1
      when :post    then  connection.setopt :POST,           1
                          connection.setopt :POSTFIELDS,     options[:payload]
                          connection.setopt :POSTFIELDSIZE,  options[:payload].size
      when :put     then  connection.setopt :CUSTOMREQUEST,  "PUT"
                          connection.setopt :POSTFIELDS,     options[:payload]
                          connection.setopt :POSTFIELDSIZE,  options[:payload].size
      when :delete  then  connection.setopt :CUSTOMREQUEST,  "DELETE"
      # else I WILL CUT YOU
      end

      if options[:headers].is_a? Hash and options[:headers].size > 0
        options[:headers].each_pair do |key_and_value|
          @request_headers = CurlFFI.slist_append(request_headers, key_and_value.join(": "))
        end
        connection.setopt :HTTPHEADER, @request_headers
      end

      if options[:response_header_handler].nil?
#        @response_header_handler = FFI::MemoryPointer.from_string("")
        @response_header_handler = FFI::MemoryPointer.new(:pointer)
        connection.setopt_str_handler :HEADERFUNCTION,  StringHandler
        connection.setopt_str_handler :WRITEHEADER,     @response_header_handler
      else
        @response_header_handler = options[:response_header_handler]
        connection.setopt_handler :HEADERFUNCTION,  CallHandler
        connection.setopt_handler :WRITEHEADER,     @response_header_handler
      end

      unless method == :head
        connection.setopt :ENCODING,  "identity, deflate, gzip"

        if options[:response_body_handler].nil?
#          @response_body_handler = FFI::MemoryPointer.from_string("")
          @response_body_handler = FFI::MemoryPointer.new(:pointer)
          connection.setopt_str_handler :WRITEFUNCTION, StringHandler
          connection.setopt_str_handler :FILE,          @response_body_handler
        else
          @response_body_handler = options[:response_body_handler]
          connection.setopt_handler :WRITEFUNCTION, CallHandler
          connection.setopt_handler :FILE,          @response_body_handler
        end
      end

      connection.setopt :URL,            FFI::MemoryPointer.from_string(url)

      # Other common options (blame streamly guy)
      connection.setopt :FOLLOWLOCATION, 1
      connection.setopt :MAXREDIRS,      3

      # This should be an option
      connection.setopt :SSL_VERIFYPEER, 0
      connection.setopt :SSL_VERIFYHOST, 0

      connection.setopt :ERRORBUFFER,    error_buffer

      return self
    end

    def connection
      @connection ||= CurlFFI::Easy.new
    end

    def error_buffer
      @error_buffer ||= FFI::MemoryPointer.new(:char, CurlFFI::ERROR_SIZE, :clear)
    end
    
    def request_headers
      @request_headers ||= FFI::MemoryPointer.from_string("")
    end
=begin

=end
    def execute
      connection.perform
      return response_body_handler
    end
    
    def self.execute(options={})
      new(options).execute
    end

  # streamly's .c internal methods:
  # @TODO: header_handler
  # @TODO: data_handler
  # @TODO: each_http_header
  # @TODO: select_error
  # @TODO: rb_streamly_new
  # @TODO: rb_streamly_init
  # @TODO: nogvl_perform
  # @TODO: rb_streamly_execute
  end
end