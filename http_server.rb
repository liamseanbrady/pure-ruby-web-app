require 'socket'

server_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, Socket::IPPROTO_TCP)
server_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
server_address = Socket.pack_sockaddr_in(2000, '127.0.0.1')
server_socket.bind(server_address)
server_socket.listen(5)

puts "HTTP Server ready to accept requests!"

loop do
  new_socket, _ = server_socket.accept
  puts "Opening a connection for request."
  while message_line = new_socket.gets
    first_header_line ||= message_line
    puts message_line
    break if message_line.chomp.empty?
  end

  file_name = first_header_line.split(' ')[1]
  first_header_line.clear

  suffix = file_name.slice(/\.(.*)/)
  content_type = case suffix
                 when '.html' then 'text/html'
                 when '.css' then 'text/css'
                 when '.jpg' then 'image/jpeg'
                 end

  document_path = (file_name == '/') ? 'documents/index.html' : "documents#{file_name}"

  puts "Sending response..."

  if File.exist?(document_path)
    content = File.open(document_path, 'r') { |f| f.read }

    new_socket.puts "HTTP/1.1 200 OK"
    new_socket.puts "Date: #{Time.now.ctime}"
    new_socket.puts "Content-Type: #{content_type}"
    new_socket.puts "Server: My HTTP Server"
    new_socket.puts "\r\n"
    new_socket.puts content
  else
    new_socket.puts "HTTP/1.1 404 Not Found"
    new_socket.puts "Date: #{Time.now.ctime}"
    new_socket.puts "Content-Type: text/html"
    new_socket.puts "Server: My HTTP Server"
    new_socket.puts "\r\n"
    new_socket.puts "<html><body><h1>404 Error - Page could not be found </h1></body></html>"
  end

  new_socket.close
  puts "Response sent and connection closed."
end