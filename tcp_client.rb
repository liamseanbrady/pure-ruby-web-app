require 'socket'

client_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, Socket::IPPROTO_TCP)
client_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
socket_address = Socket.pack_sockaddr_in(53000, '127.0.0.1')
client_socket.bind(socket_address)

server_address = Socket.pack_sockaddr_in(2000, '127.0.0.1')
client_socket.connect(server_address)

while line = client_socket.gets
  puts "#{line}\n"
end

client_socket.close



