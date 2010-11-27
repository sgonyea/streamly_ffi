# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler'

Bundler.require(:default)
Bundler.require(:benchmark)

require 'net/http'
require 'streamly_ffi'
require 'benchmark'

url   = ARGV[0]
uri   = URI.parse(url)
iters = (ARGV[1] || 100).to_i

Benchmark.bmbm do |x|
  x.report("StreamlyFFI") do
    iters.times do
      out = StreamlyFFI.get(url)
    end
  end

  x.report("Streamly") do
    iters.times do
      out = Streamly.get(url)
    end
  end if RUBY_ENGINE == "ruby"

  x.report("Curb") do
    iters.times do
      out = Curl::Easy.perform(url).body_str
    end
  end if RUBY_ENGINE == "ruby"
=begin
  x.report do
    puts "Curb (Persistent)"
    curb = Curl::Easy.new(url)
    iters.times do
      out = 
      perform(url).body_str
    end
  end if RUBY_ENGINE == "ruby"
=end
  x.report("Excon") do
    iters.times do
      out = Excon.get(url).body
    end
  end

  x.report("StreamlyFFI (Persistent)") do
    conn = StreamlyFFI::Connection.new
    iters.times do
      out = conn.get(url)
    end
  end

  x.report("StreamlyFFI (Cheating)") do
    conn = StreamlyFFI::Connection.new(url, :method => :get)
    iters.times do
      out = conn.perform
    end
  end

  x.report("Excon (Persistent)") do
    excon = Excon.new(url)
    iters.times do
      out = excon.request(:method => 'get').body
    end
  end

  x.report("rest-client") do
    iters.times do
      out = RestClient.get(url, {"Accept-Encoding" => "identity, deflate, gzip"})
    end
  end

  x.report("`curl`") do
    iters.times do
      out = `curl --compressed --silent #{url}`
    end
  end

  x.report("Net::HTTP") do
    iters.times do
      Net::HTTP.start(uri.host, uri.port) {|http| http.get("/").body }
    end
  end

  x.report("Net::HTTP (Persistent)") do
    Net::HTTP.start(uri.host, uri.port) do |http|
      iters.times do
        http.get("/").body
      end
    end
  end
end