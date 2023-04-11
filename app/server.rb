require "socket"
require_relative "./commands"
require_relative "./resp_parser"

# This is the main class of this Redis implementation
#
# It is responsible for starting the server and handling the communication with the clients
class RedisServer
  CLOCK_HZ = 5
  include Commands
  def initialize(port)
    @port = port
    @data_store = {}
    @next_clean_timestamp = Time.now.to_i + CLOCK_HZ
  end

  # Starts the server and listens for incoming connections
  def start
    puts("Starting Redis server!")

    server = TCPServer.new(@port)
    sockets = [server]

    loop do
      expire_keys if should_expire?

      ready_sockets, _, _ = IO.select(sockets, nil, nil, 1)
      ready_sockets&.each do |socket|
        if socket == server
          client = server.accept
          puts "New client connected: #{client}"
          sockets << client
        else
          begin
            data = socket.read_nonblock(1024)
            puts "Received data"
            command, arguments = RESPParser.new(data).decode
            response = execute_command(command, arguments)
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

  def expire_keys
    puts "Expiring keys..."
    @data_store.each do |key, entry|
      next if entry[:expiry] == 0
      if Time.now.to_i >= entry[:expiry]
        @data_store.delete(key)
      end
    end
    @next_clean_timestamp = Time.now.to_i + CLOCK_HZ
    puts "Keys expired..."
  end

  def should_expire?
    Time.now.to_i >= @next_clean_timestamp
  end

  # @param [String] command
  # @return [String] A string containing the response to the command in the Redis protocol format
  def execute_command(command, arguments)
    case command
    when "ping"
      ping_command
    when "echo"
      echo_command(arguments)
    when "set"
      @data_store = set_command(arguments, @data_store)
      "+OK\r\n"
    when "get"
      get_command(arguments, @data_store)
    else
      error_command(command)
    end
  end
end

RedisServer.new(6379).start
