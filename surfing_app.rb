require 'rack'
require 'pry'
require 'mustache'

class Surfing
  DATA = {
    "journal" => [
      {'title' => 'Huge Waves',
      'body' => "Today's waves are big."},
      {'title' => 'Massive Waves',
      'body' => "Today's waves are massive."}
    ]
  }

  def call(env)
    request = Rack::Request.new(env)
    name_hash = request.params
    DATA.merge!(name_hash) if !name_hash.nil?
    if env['PATH_INFO'] == '/'
      env['PATH_INFO'] = '/index.html'
      env['REQUEST_PATH'] = '/index.html'
      template = File.read('templates/index.mustache')
      body = Mustache.render(template, DATA)
      [302, {}, [body]]
    else
      Rack::File.new('documents').call(env)
    end
  end
end