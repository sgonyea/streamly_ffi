# encoding: UTF-8
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'streamly_ffi/version'
require 'streamly_ffi/base'

module StreamlyFFI
  autoload :Request,            'streamly_ffi/request'
  autoload :Connection,         'streamly_ffi/connection'
  autoload :PersistentRequest,  'streamly_ffi/persistent_request'

  class Error               < StandardError; end
  class UnsupportedProtocol < StandardError; end
  class URLFormatError      < StandardError; end
  class HostResolutionError < StandardError; end
  class ConnectionFailed    < StandardError; end
  class PartialFileError    < StandardError; end
  class TimeoutError        < StandardError; end
  class TooManyRedirects    < StandardError; end

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
  def self.head(url, headers=nil, &block)
    opts = {:method => :head, :url => url, :headers => headers}
    opts.merge!({:response_header_handler => block}) if block_given?
    Request.execute(opts)
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
  def self.get(url, headers=nil, &block)
    opts = {:method => :get, :url => url, :headers => headers}
    opts.merge!({:response_body_handler => block}) if block_given?
    Request.execute(opts)
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
  def self.post(url, payload, headers=nil, &block)
    opts = {:method => :post, :url => url, :payload => payload, :headers => headers}
    opts.merge!({:response_body_handler => block}) if block_given?
    Request.execute(opts)
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
  def self.put(url, payload, headers=nil, &block)
    opts = {:method => :put, :url => url, :payload => payload, :headers => headers}
    opts.merge!({:response_body_handler => block}) if block_given?
    Request.execute(opts)
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
  def self.delete(url, headers={}, &block)
    opts = {:method => :delete, :url => url, :headers => headers}
    opts.merge!({:response_body_handler => block}) if block_given?
    Request.execute(opts)
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
  def self.connect
    Connection.new
  end
end
