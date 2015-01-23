require 'socket'
require 'logger'
require 'rack'

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

    @logger.info("HTTP Server ready to accept requests on #{@host}:#{@port}!")
    loop do
      connection, remote_addr_info = server_socket.accept
      @logger.info "Opening a connection for request:"
      message_line = connection.gets
      @logger.info message_line
      env = parse_http_header(message_line)
      begin
        message_line = connection.gets
      end until message_line.chomp == ""
      @logger.info "Sending response..."
      status, headers, body = app.call(env)
      write_status(connection, status)
      write_headers(connection, headers)
      write_body(connection, body)
      connection.close
      @logger.info "Response sent and connection closed."
    end
  end

  def parse_http_header(header_string)
    method, path, protocol = header_string.split(' ')
    {method: method, path: path, protocol: protocol}
  end

  def write_status(connection, status_code)
    connection.puts "HTTP/1.1 #{status_code} #{status_word(status_code)}"
  end

  def write_headers(connection, headers)
    headers.each do |key, value|
      connection.puts "#{key}: #{value}\r\n"
    end
    connection.puts "Date: #{Time.now.ctime}"
    connection.puts "Server: Tiny Web Server"
    connection.puts "\r\n"
  end

  def write_body(connection, body)
    body.each do |chunk|
      connection.puts chunk
    end
  end

  def status_word(response_code)
    case response_code
    when 200
      "OK"
    when 404
      "NOT FOUND"
    end
  end

end

module Rack
  module Handler
    class TinyWebServer
      def self.run(app, options)
        host = options[:host] || '127.0.0.1'
        port = options[:port] || 2000
        ::TinyWebServer.new(host, port).run(app)
      end
    end
  end
end