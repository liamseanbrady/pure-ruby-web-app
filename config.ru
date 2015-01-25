require 'rack'

run Rack::File.new("documents")