require 'socket'

client_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, Socket::IPPROTO_TCP)
client_address = Socket.pack_sockaddr_in(12000, '127.0.0.1')
client_socket.bind(client_address)

server_address = Socket.pack_sockaddr_in(2000, '127.0.0.1')
client_socket.connect(server_address)

client_socket.puts "GET /hello_world.html HTTP/1.1\r\n"
client_socket.puts "Accept: text/html"
client_socket.puts "Accept-Charset: UTF-8"
client_socket.puts "User-Agent: My HTTP Client"
client_socket.puts "\r\n"

while line = client_socket.gets
  puts line  
end

client_socket.close
