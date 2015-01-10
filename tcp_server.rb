require 'socket'

server = TCPServer.open('localhost', 2000)
loop do
  connection = server.accept
  puts "Opening a connection upon request."
  connection.write("It is now #{Time.now.ctime}")
  connection.write "Bye!"
  connection.write "#{connection.peeraddr}"
  connection.close
  puts "Closing connection."
end