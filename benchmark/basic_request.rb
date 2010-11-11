# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'net/http'
require 'rest_client'
require 'curb'
require 'streamly'
require 'streamly_ffi'
require 'benchmark'

url = ARGV[0]

Benchmark.bmbm do |x|
  x.report do
    puts "StreamlyFFI"
    (ARGV[1] || 1).to_i.times do
      StreamlyFFI.get(url)
    end
  end

  x.report do
    puts "Streamly"
    (ARGV[1] || 1).to_i.times do
      Streamly.get(url)
    end
  end

  x.report do
    puts "Curb"
    (ARGV[1] || 1).to_i.times do
      Curl::Easy.perform(url)
    end
  end

  x.report do
    puts "StreamlyFFI2"
    conn = StreamlyFFI::Connection.new
    (ARGV[1] || 1).to_i.times do
      conn.get(url)
    end
  end

  x.report do
    puts "`curl`"
    (ARGV[1] || 1).to_i.times do
      `curl --compressed --silent #{url}`
    end
  end

  x.report do
    puts "rest-client"
    (ARGV[1] || 1).to_i.times do
      RestClient.get(url, {"Accept-Encoding" => "identity, deflate, gzip"})
    end
  end
end