require 'pry'
require 'mustache'

class Surfing
  DATA = {
    "journal" => [
      {'title' => %q{A Look Back: "Huge Waves!"},
      'body' => %q{"Today's waves are record setting! 10 foot waves coming from the south and heading to the north. Hide your kids, hide your wife. Don't come out without your board!" A write up about the record setting day of surfing that went down in the history books. Don't miss this recount of the biggest surfing day in Carmel, CA.}},
      {'title' => %q{Feature Article: Johnny Smith},
      'body' => %q{Listen to local professional surfer, Johnny Smith, talk about the ups and downs of having a career in professional surfing. Johnny shares insight into his surfing philosophy, how he ended up where he is, and where he's planning on going.}},
      {'title' => %q{Tips: How to Catch the Waves You Want},
      'body' => %q{Local surfing instructor shares his secrets to watching the ocean and catching the waves that are worth your effort. Being choosy is an advantage with this strategy and will ensure a fun and fulfilling day of surfing.}},
      {'title' => %q{Feature Article: Attacked by a Shark and Still Surfing},
      'body' => %q{Our own hometown hero shares the terrifying story about a nearly fatal shark attack that took an arm but only fanned the fire of passion for a surfer's craft. This article shows us that even in the face of adversity, there is much to live for and much to achieve.}}
    ]
  }

  def call(env)
    request = Rack::Request.new(env)
    name_hash = request.params
    DATA.merge!(name_hash) if !name_hash.nil?
    DATA['journal'].map do |j| 
      j['body'] = j['body'].slice(0..199)
      j
    end
    if env['PATH_INFO'] == '/'
      env['PATH_INFO'] = '/index.html'
      env['REQUEST_PATH'] = '/index.html'
      template = File.read('templates/index_truncated.mustache')
      body = Mustache.render(template, DATA)
      [302, {}, [body]]
    else
      Rack::File.new('documents').call(env)
    end
  end
end

