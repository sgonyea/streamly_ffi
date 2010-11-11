$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "curl_ffi"
require "singleton"

module StreamlyFFI
  class Request
    include Singleton
    include StreamlyFFI::Base

    def self.execute(options={})
      new.execute(options)
    end
  end
end