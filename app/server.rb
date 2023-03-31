require "socket"

class RedisServer
  def initialize(port)
    @port = port
  end

  def start
    puts("Starting Redis server!")

    server = TCPServer.new(@port)
    sockets = [server]

    loop do
      ready_sockets, _, _ = IO.select(sockets)
      ready_sockets.each do |socket|
        if socket == server
          client = server.accept
          puts "New client connected: #{client}"
          sockets << client
        else
          begin
            data = socket.read_nonblock(1024)
            puts "Received data"
            command = parse_request(data)
            response = execute_command(command)
            socket.puts response
          rescue EOFError
            puts "Client disconnected: #{socket}"
            sockets.delete(socket)
          end
        end
      end
    end
  end

  private

  def parse_request(raw_data)
    raw_data.split("\r\n").last
  end

  def execute_command(command)
    case command
    when "ping"
      ping_command
    else
      error_command(command)
    end
  end

  def ping_command
    "+PONG\r\n"
  end

  def error_command(command)
    "-Unknown command #{command}\r\n"
  end
end

RedisServer.new(6379).start
