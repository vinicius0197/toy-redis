require "socket"
require_relative "./commands"

# This is the main class of this Redis implementation
#
# It is responsible for starting the server and handling the communication with the clients
class RedisServer
  include Commands
  def initialize(port)
    @port = port
  end

  # Starts the server and listens for incoming connections
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

  # @param [String] raw_data
  # @return [String]
  def parse_request(raw_data)
    raw_data.split("\r\n").last
  end

  # @param [String] command
  # @return [String] A string containing the response to the command in the Redis protocol format
  def execute_command(command)
    case command
    when "ping"
      ping_command
    else
      error_command(command)
    end
  end
end

RedisServer.new(6379).start
