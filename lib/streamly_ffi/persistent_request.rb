$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "curl_ffi"

module StreamlyFFI
  class PersistentRequest
    include StreamlyFFI::Base

    def [](_sym)
        send _sym
    end

    def escape(_string)
      connection.escape(_string)
    end
  end
end
