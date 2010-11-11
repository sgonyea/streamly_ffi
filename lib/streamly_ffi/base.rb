module StreamlyFFI
  module Base
    alias __method__ method

    attr_accessor :url, :method, :default_write_handler, :default_header_handler

    def execute(options={})
      set_options(options).perform

      CurlFFI.slist_free_all(@request_headers) if @request_headers

      connection.reset

      resp  = if(options.has_key?(:response_header_handler) or options.has_key?(:response_body_handler))
                nil
              elsif(options[:method] == :head && response_header.respond_to?(:to_str))
                response_header
              elsif(response_body.is_a?(String))
                response_body
              else
                nil
              end

      return resp
    end

    def perform
      connection.perform
    end

    def set_options(options={})
      @url      = options[:url]     if options.has_key?(:url)     # Make sure @url is set, if not
      @method   = options[:method]  if options.has_key?(:method)  # Make sure @method is set, if not
      @payload  = options[:payload]

      @response_body          = nil
      @response_header        = nil
      @custom_header_handler  = nil
      @custom_write_handler   = nil

      # url should be a string that doesn't suck
      # method should be :post, :get, :put, :delete, :head
      # options should contain any of the following keys:
      #   :headers, :response_header_handler, :response_body_handler, :payload (required if method = :post / :put)

      case @method
      when :get     then  connection.setopt :HTTPGET,        1
      when :head    then  connection.setopt :NOBODY,         1
      when :post    then  connection.setopt :POST,           1
                          connection.setopt :POSTFIELDS,     @payload
                          connection.setopt :POSTFIELDSIZE,  @payload.size
      when :put     then  connection.setopt :CUSTOMREQUEST,  "PUT"
                          connection.setopt :POSTFIELDS,     @payload
                          connection.setopt :POSTFIELDSIZE,  @payload.size
      when :delete  then  connection.setopt :CUSTOMREQUEST,  "DELETE"
      # else I WILL CUT YOU
      end

      if options.has_key?(:headers) and not options[:headers].nil?
        options[:headers].each_pair do |key_and_value|
          self.request_headers = CurlFFI.slist_append(self.request_headers, key_and_value.join(": "))
        end
        connection.setopt :HTTPHEADER, @request_headers
      end

      if options.has_key?(:response_header_handler)
        @custom_header_handler = options[:response_header_handler]
        set_header_handler(:custom_header_callback)
      else
        set_header_handler
      end

      if options.has_key?(:response_body_handler)
        @custom_write_handler = options[:response_body_handler]
        set_write_handler(:custom_write_callback)
      else
        set_write_handler
      end

      connection.setopt :ENCODING,        "identity, deflate, gzip" unless @method == :head
      connection.setopt :URL,             @url

      # Other common options (blame streamly guy)
      connection.setopt :FOLLOWLOCATION,  1
      connection.setopt :MAXREDIRS,       3
      # @TODO: This should be an option
      connection.setopt :SSL_VERIFYPEER,  0
      connection.setopt :SSL_VERIFYHOST,  0

      connection.setopt :ERRORBUFFER,     self.error_buffer

      return self
    end

    def connection
      @connection ||= CurlFFI::Easy.new
    end

    def error_buffer
      @error_buffer ||= FFI::MemoryPointer.new(:char, CurlFFI::ERROR_SIZE, :clear)
    end
    alias :error    :error_buffer

    def request_headers
      @request_headers ||= FFI::MemoryPointer.from_string("")
    end

    def response_body
      @response_body ||= ""
    end
    alias :response :response_body
    alias :body     :response_body

    def response_header
      @response_header ||= ""
    end
    alias :headers  :response_header

    def set_write_handler(_callback=:default_write_callback)
      connection.setopt(:WRITEFUNCTION, FFI::Function.new(:size_t, [:pointer, :size_t, :size_t,], &self.__method__(_callback)))
    end

    def set_header_handler(_callback=:default_header_callback)
      connection.setopt(:HEADERFUNCTION, FFI::Function.new(:size_t, [:pointer, :size_t, :size_t], &self.__method__(_callback)))
    end

    def default_write_callback(string_ptr, size, nmemb)
      length = size * nmemb
      response_body << string_ptr.read_string(length)

      return length
    end

    def default_header_callback(string_ptr, size, nmemb)
      length = size * nmemb
      response_header << string_ptr.read_string(length)

      return length
    end

    def custom_write_callback(string_ptr, size, nmemb)
      length = size * nmemb
      @custom_write_handler.call(string_ptr.read_string(length))

      return length
    end

    def custom_header_callback(string_ptr, size, nmemb)
      length = size * nmemb
      @custom_header_handler.call(string_ptr.read_string(length))

      return length
    end
  end
end
