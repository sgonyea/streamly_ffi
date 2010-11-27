require 'rubygems'
require 'sinatra'

disable :logging, :dump_errors, :sessions, :clean_trace, :show_exceptions

get '/' do
  "Hello, #{params[:name]}".strip
end

post '/' do
  "Hello, #{params[:name]}".strip
end

put '/' do
  "Hello, #{params[:name]}".strip
end

delete '/' do
  "Hello, #{params[:name]}".strip
end
