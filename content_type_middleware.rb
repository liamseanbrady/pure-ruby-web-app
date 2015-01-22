class ContentType
  def initialize(app)
    @app = app
  end

  def call(env)
    suffix = env[:path].slice(/\.(.*)/)
    status, headers, body = @app.call(env)
    puts "#{headers}"
    if status == 200
      headers.merge!({"Content-Type" => content_type(suffix)})
    elsif status == 404
      headers.merge!({"text/html" => "text/html"})
    end
    puts "#{headers}"
    [status, headers, body]
  end


  def content_type(suffix)
    case suffix
    when ".html" then 'text/html'
    when ".css" then 'text/css'
    when '.jpg' then 'image/jpeg'
    end
  end
end