require 'socket'

server = TCPServer.open('localhost', 2000)
server_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, Socket::IPPROTO_TCP)
server_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
socket_address = Socket.pack_sockaddr_in(2000, '127.0.0.1')
server_socket.bind(socket_address)
server_socket.listen(5)

loop do
  new_socket, _ = server_socket.accept
  puts "Opening a connection upon request."
  puts "Connected to #{new_socket.remote_address.ip_address}:#{new_socket.remote_address.ip_port}"
  new_socket.write "It is now #{Time.now.ctime}\r\n"
  new_socket.write "Bye!"
  new_socket.close
  puts "Closing connection."
end