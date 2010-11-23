module StreamlyFFI
  module Base
    alias __method__ method

    attr_accessor :url, :method, :default_write_handler, :default_header_handler

    DEFAULT_CURL_ENCODING = "identity, deflate, gzip"

    def execute(options={})
      connection.reset
      set_options(options).perform

      CurlFFI.slist_free_all(@request_headers) if @request_headers

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

    # Set/add request headers in Curl's slist
    #   @param [Hash, Array<Hash>, Set<Hash>] headers Any number of headers to be added to curl's slist. Ultimate form
    #     must be a Hash; multiple Hashes with the same key (and different value) can be placed in an Array, if desired.
    def set_headers(headers)
      case headers
      when Hash
        headers.each_pair do |k_v|
          self.request_headers = CurlFFI.slist_append(self.request_headers, k_v.join(": "))
        end
      when Array, Set
        headers.each do |header|
          header.each_pair do |k_v|
            self.request_headers = CurlFFI.slist_append(self.request_headers, k_v.join(": "))
          end
        end
      end
      return self.request_headers
    end # def set_headers

    # Set one of libCurl's many options here
    #   @param [Hash] options One or more options to set within the current (future) Curl request
    #   @option options [String]  :url      The full URL of the destination
    #   @option options [Symbol]  :method   The method in which to send the request (Commonly, :get, :head, :post, :put, :delete)
    #   @option options [String]  :payload  The data to be sent with your request. Only valid for :post and :put
    #   @option options [Proc]    :response_header_handler  A proc that may be called as headers are received from the host. Headers are received in "chunks" and this will allow you to interact with those chunks, as they become available.
    #   @option options [Proc]    :response_body_handler    A proc that may be called as content is received from the host. Content is received in "chunks" and this will allow you to interact with those chunks, as they become available.
    #   @option options [Hash,Array]  :headers  The headers you'd like to send to the remote destination. This may be a Hash or an Array. A given Header's key may have multiple values; in such a case, you must supply those multiple values in an Array of Hashes
    def set_options(options={})
      @url      = options[:url].dup     if options.has_key?(:url)     # Make sure @url is set, if not
      @method   = options[:method]      if options.has_key?(:method)  # Make sure @method is set, if not
      @payload  = options[:payload].dup if options.has_key?(:payload)

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

      if options.has_key?(:headers)
        connection.setopt(:HTTPHEADER, set_headers(options[:headers])) unless options[:headers].nil?
      end

      if options.has_key?(:response_header_handler)
        @custom_header_handler = options[:response_header_handler]
        set_header_handler(:custom_header_callback)
      else
        @response_header = ""
        set_header_handler
      end

      if options.has_key?(:response_body_handler)
        @custom_write_handler = options[:response_body_handler]
        set_write_handler(:custom_write_callback)
      else
        @response_body = ""
        set_write_handler
      end

      connection.setopt :ENCODING,        DEFAULT_CURL_ENCODING unless @method == :head
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
      @request_headers ||= FFI::MemoryPointer.new(:pointer)
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
      @_write_handler = FFI::Function.new(:size_t, [:pointer, :size_t, :size_t,], &self.__method__(_callback))

      connection.setopt(:WRITEFUNCTION, @_write_handler)
    end

    def set_header_handler(_callback=:default_header_callback)
      @_header_handler = FFI::Function.new(:size_t, [:pointer, :size_t, :size_t], &self.__method__(_callback))
      connection.setopt(:HEADERFUNCTION, @_header_handler)
    end

    def default_write_callback(string_ptr, size, nmemb)
      length  = size * nmemb
      @response_body << string_ptr.read_string(length).dup

      return length
    end

    def default_header_callback(string_ptr, size, nmemb)
      length  = size * nmemb
      @response_header << string_ptr.read_string(length).dup

      return length
    end

    def custom_write_callback(string_ptr, size, nmemb)
      length  = size * nmemb
      @_wcall = string_ptr.read_string(length)
      @custom_write_handler.call(string_ptr.read_string(length).dup)

      return length
    end

    def custom_header_callback(string_ptr, size, nmemb)
      length  = size * nmemb
      @_hcall = string_ptr.read_string(length)
      @custom_header_handler.call(string_ptr.read_string(length).dup)

      return length
    end
  end
end
