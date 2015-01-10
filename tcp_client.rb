require 'socket'

connection = TCPSocket.open('localhost', 2000)

while line = connection.gets
  puts line
end
connection.close