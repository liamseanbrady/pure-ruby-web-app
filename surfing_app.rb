require 'rack'
require 'pry'

class Surfing
  def call(env)
    if env['PATH_INFO'] == '/'
      env['PATH_INFO'] = '/index.html'
      env['REQUEST_PATH'] = '/index.html'
      [302, {} , [File.read('documents/index.html')]]
    else
      Rack::File.new('documents').call(env)
    end
  end
end