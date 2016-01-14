This is the original config file for configuring the Rack app
```ruby
  require 'rack'
  require './tiny_web_server'
  require './surfing_app'
  require './content_type_middleware'

  app = Rack::Builder.new do
    use ContentType
    run Surfing.new
  end

  Rack::Handler::TinyWebServer.run app, host: '127.0.0.1', port: 9292
```
