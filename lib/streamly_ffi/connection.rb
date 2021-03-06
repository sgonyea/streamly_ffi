module StreamlyFFI
  class Connection

    attr_accessor :curl_handle, :init_url

    def initialize(url=nil, options=nil)
      unless url.nil?
        @init_url     = url
        options       = {} if options.nil?
        options[:url] = @init_url
      end

      @curl_handle = StreamlyFFI::PersistentRequest.new(options)
    end

    # A helper method to make HEAD requests a dead-simple one-liner
    #
    # Example:
    #   Streamly.head("www.somehost.com/some_resource/1")
    #
    #   Streamly.head("www.somehost.com/some_resource/1") do |header_chunk|
    #     # do something with _header_chunk_
    #   end
    #
    # Parameters:
    # +url+ should be a String, the url to request
    # +headers+ should be a Hash and is optional
    # 
    # This method also accepts a block, which will stream the response headers in chunks to the caller
    def head(url, headers=nil, &block)
      opts = {:method => :head, :url => url, :headers => headers}
      opts[:response_header_handler] = block if block_given?
      @curl_handle.execute(opts)
    end

    # A helper method to make HEAD requests a dead-simple one-liner
    #
    # Example:
    #   Streamly.get("www.somehost.com/some_resource/1")
    #
    #   Streamly.get("www.somehost.com/some_resource/1") do |chunk|
    #     # do something with _chunk_
    #   end
    #
    # Parameters:
    # +url+ should be a String, the url to request
    # +headers+ should be a Hash and is optional
    # 
    # This method also accepts a block, which will stream the response body in chunks to the caller
    def get(url, headers=nil, &block)
      opts = {:method => :get, :url => url, :headers => headers}
      opts[:response_body_handler] = block if block_given?
      @curl_handle.execute(opts)
    end

    # A helper method to make HEAD requests a dead-simple one-liner
    #
    # Example:
    #   Streamly.post("www.somehost.com/some_resource", "asset[id]=2&asset[name]=bar")
    #
    #   Streamly.post("www.somehost.com/some_resource", "asset[id]=2&asset[name]=bar") do |chunk|
    #     # do something with _chunk_
    #   end
    #
    # Parameters:
    # +url+ should be a String (the url to request) and is required
    # +payload+ should be a String and is required
    # +headers+ should be a Hash and is optional
    # 
    # This method also accepts a block, which will stream the response body in chunks to the caller
    def post(url, payload, headers=nil, &block)
      opts = {:method => :post, :url => url, :payload => payload, :headers => headers}
      opts[:response_body_handler] = block if block_given?
      @curl_handle.execute(opts)
    end

    # A helper method to make HEAD requests a dead-simple one-liner
    #
    # Example:
    #   Streamly.put("www.somehost.com/some_resource/1", "asset[name]=foo")
    #
    #   Streamly.put("www.somehost.com/some_resource/1", "asset[name]=foo") do |chunk|
    #     # do something with _chunk_
    #   end
    #
    # Parameters:
    # +url+ should be a String (the url to request) and is required
    # +payload+ should be a String and is required
    # +headers+ should be a Hash and is optional
    # 
    # This method also accepts a block, which will stream the response body in chunks to the caller
    def put(url, payload, headers=nil, &block)
      opts = {:method => :put, :url => url, :payload => payload, :headers => headers}
      opts[:response_body_handler] = block if block_given?
      @curl_handle.execute(opts)
    end

    # A helper method to make HEAD requests a dead-simple one-liner
    #
    # Example:
    #   Streamly.delete("www.somehost.com/some_resource/1")
    #
    #   Streamly.delete("www.somehost.com/some_resource/1") do |chunk|
    #     # do something with _chunk_
    #   end
    #
    # Parameters:
    # +url+ should be a String, the url to request
    # +headers+ should be a Hash and is optional
    # 
    # This method also accepts a block, which will stream the response body in chunks to the caller
    def delete(url, headers={}, &block)
      opts = {:method => :delete, :url => url, :headers => headers}
      opts[:response_body_handler] = block if block_given?
      @curl_handle.execute(opts)
    end

    def escape(_string)
      @curl_handle.escape(_string)
    end

    def perform
      @curl_handle.perform
    end
  end
end