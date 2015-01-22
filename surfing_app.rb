class Surfing
  def call(env)
    document_name = env[:path].slice(/\/(.*)/)
    document_path = "documents#{document_name}"
    if File.exists?(document_path)
      [200, {}, [File.read(document_path)]]
    else
      [404, {}, ["<html><body><h1>Can't find the page you requested </h1></body></html>"]]
    end
  end
end