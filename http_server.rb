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
    puts message_line
    break if message_line.chomp == ''
  end

  puts "Sending response..."
  new_socket.puts "HTTP/1.1 200 OK"
  new_socket.puts "Date: #{Time.now.ctime}"
  new_socket.puts "Content-Type: text/html"
  new_socket.puts "Server: My HTTP Server"
  new_socket.puts "\r\n"
  new_socket.puts "Hi there, greetings from the server!"
  new_socket.close
  puts "Response sent and connection closed."
end