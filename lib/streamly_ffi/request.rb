$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "curl_ffi"
require "singleton"

module StreamlyFFI
  class Request
    include Singleton

    alias __method__ method

    attr_reader :url, :method

    # @TODO: Argumenting Checking + Error Handling
    def initialize(options={})
      url     = options[:url]
      method  = options[:method]
      
      @response_body          = nil
      @response_header        = nil
      @custom_header_handler  = nil
      @custom_write_handler   = nil

      # url should be a string that doesn't suck
      # method should be :post, :get, :put, :delete, :head
      # options should contain any of the following keys:
      #   :headers, :response_header_handler, :response_body_handler, :payload (required if method = :post / :put)

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
          request_headers = CurlFFI.slist_append(request_headers, key_and_value.join(": "))
        end
        connection.setopt :HTTPHEADER, request_headers
      end

      @custom_header_handler  = options[:response_header_handler] if options.has_key?(:response_header_handler)
      @custom_write_handler   = options[:response_body_handler]   if options.has_key?(:response_body_handler)

      default_header_handler
      default_write_handler

      
      connection.setopt :ENCODING,        "identity, deflate, gzip" unless method == :head
      connection.setopt :URL,             url

      # Other common options (blame streamly guy)
      connection.setopt :FOLLOWLOCATION,  1
      connection.setopt :MAXREDIRS,       3
      # @TODO: This should be an option
      connection.setopt :SSL_VERIFYPEER,  0
      connection.setopt :SSL_VERIFYHOST,  0

      connection.setopt :ERRORBUFFER,     error_buffer

      return self # I am a terrible hack. I should abandon the singleton
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
    
    def response_body
      @response_body ||= ""
    end
    
    def response_header
      @response_header ||= ""
    end

    def execute
      status = connection.perform

      # @TODO: Intelligent error stuff
#      raise Streamly::Error if status 

      CurlFFI.slist_free_all(@request_headers) if @request_headers

      @connection.reset
    end
    
    def self.execute(options={})
      request = new(options)

      request.execute

      return nil if(options.has_key?(:response_header_handler) or options.has_key?(:response_body_handler))

      resp  = if(options[:method] == :head && request.response_header.respond_to?(:to_str))
                request.response_header
              elsif(request.response_body.is_a?(String))
                request.response_body
              else
                nil
              end

      return resp
    end

    def default_write_handler
      connection.setopt(:WRITEFUNCTION, FFI::Function.new(:size_t, [:pointer, :size_t, :size_t,], &self.__method__(:write_callback)))
    end

    def default_header_handler
      connection.setopt(:HEADERFUNCTION, FFI::Function.new(:size_t, [:pointer, :size_t, :size_t], &self.__method__(:header_callback)))
    end

    def write_callback(string_ptr, size, nmemb)
      length = size * nmemb

      if(@custom_write_handler)
        @custom_write_handler.call(string_ptr.read_string(length))
      else
        response_body << string_ptr.read_string(length)
      end

      return length
    end

    def header_callback(string_ptr, size, nmemb)
      length = size * nmemb

      if(@custom_header_handler)
        @custom_header_handler.call(string_ptr.read_string(length))
      else
        response_header << string_ptr.read_string(length)
      end

      return length
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