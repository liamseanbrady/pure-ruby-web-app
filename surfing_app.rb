class Surfing
  def call(env)
    document_name = env[:path].slice(/\/(.*)/)
    suffix = document_name.slice(/\.(.*)/)
    content_type = case suffix
                  when ".html" then 'text/html'
                  when ".css" then 'text/css'
                  when '.jpg' then 'image/jpeg'
                  end
    document_path = "documents#{document_name}"
    if File.exists?(document_path)
      [200, {'Content-Type' => content_type}, [File.read(document_path)]]
    else
      [404, {}, ["<html><body><h1>Can't find the page you requested </h1></body></html>"]]
    end
  end
end