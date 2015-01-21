require 'socket'
require 'logger'
require './surfing_app'

class TinyWebServer
  def initialize(host, port)
    @host = host
    @port = port
    @logger = Logger.new(STDOUT)
  end

  def run(app)
    server_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, Socket::IPPROTO_TCP)
    server_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    server_address = Socket.pack_sockaddr_in(@port, @host)
    server_socket.bind(server_address)
    server_socket.listen(5)

    @logger.info("HTTP Server ready to accept requests!")
    loop do
      connection, remote_addr_info = server_socket.accept
      @logger.info "Opening a connection for request:"
      message_line = connection.gets
      @logger.info message_line
      env = parse_http_header(message_line)
      begin
        message_line = connection.gets
      end until message_line.chomp == ""
      response = app.call(env)
      @logger.info "Sending response..."
      connection.puts "HTTP/1.1 #{response[0]} #{response_status(response[0])}"
      connection.puts "Date: #{Time.now.ctime}"
      connection.puts "Content-Type: #{response[1]['Content-Type']}"
      connection.puts "Server: Tiny Web Server"
      connection.puts
      connection.puts response[2][0]
      connection.close
      @logger.info "Response sent and connection closed."
    end
  end

  def parse_http_header(header_string)
    method, path, protocol = header_string.split(' ')
    {method: method, path: path, protocol: protocol}
  end

  def response_status(response_code)
    case response_code
    when 200
      "OK"
    when 404
      "NOT FOUND"
    end
  end
end

TinyWebServer.new('127.0.0.1', 2000).run(Surfing.new)