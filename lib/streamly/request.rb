$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "curl_ffi"
require "singleton"

module Streamly
  class Request
    include Singleton

    attr_reader :response_header_handler, :response_body_handler, :url, :method

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
          request_headers = CurlFFI.slist_append(request_headers, key_and_value.join(": "))
        end
        connection.setopt :HTTPHEADER, request_headers
      end

      if options[:response_header_handler].nil?
        connection.setopt_handler :HEADERFUNCTION, data_handler(response_header_handler = "")
      else
        response_header_handler = options[:response_header_handler]

        if(response_header_handler.is_a? String)
          connection.setopt_handler :HEADERFUNCTION,  data_handler(response_header_handler)
        else
          connection.setopt_handler :HEADERFUNCTION,  data_handler
          connection.setopt :WRITEHEADER,             response_header_handler
        end
      end

      unless method == :head
        connection.setopt :ENCODING,  "identity, deflate, gzip"

        if options[:response_body_handler].nil?
          connection.setopt_handler :WRITEFUNCTION,  data_handler(response_body_handler = "")
        else
          response_body_handler = options[:response_body_handler]

          if(response_body_handler.is_a? String)
            connection.setopt_handler :WRITEFUNCTION, data_handler(response_body_handler)
          else
            connection.setopt_handler :WRITEFUNCTION, data_handler
            connection.setopt :FILE,                  response_body_handler
          end
        end
      end

      connection.setopt :URL,             url

      # Other common options (blame streamly guy)
      connection.setopt :FOLLOWLOCATION,  1
      connection.setopt :MAXREDIRS,       3

      # This should be an option
      connection.setopt :SSL_VERIFYPEER,  0
      connection.setopt :SSL_VERIFYHOST,  0

      connection.setopt :ERRORBUFFER,     error_buffer

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

    def execute
      status = connection.perform

      # @TODO: Intelligent error stuff
#      raise Streamly::Error if status 

      CurlFFI.slist_free_all(@request_headers) if @request_headers

      @connection.reset
    end
    
    def self.execute(options={})
      puts "-----------------------"
      10.times{ puts "" }
      request = new(options)
      resp    = request.execute

      puts "--options"
      puts options.inspect
      
      response  = if(options[:method] == :head) #and @response_header_handler.respond_to?(:to_str))
                    puts "__:head__"
                    request.response_header_handler
                  elsif(request.response_body_handler.is_a? String)
                    puts "__:body__"
                    request.response_body_handler
                  else
                    nil
                  end
      
      return(response)
    end

    def data_handler(_string=nil)
      Proc.new{ |stream, size, nmemb, handler|
        puts "---stream---------"
        puts stream.inspect
        puts "---handler--------"
        puts handler.inspect
        puts "---_string--------"
        puts _string.inspect

        if(_string)
          _string << stream
        else
          handler.call(stream)
        end

        size * nmemb
      }
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