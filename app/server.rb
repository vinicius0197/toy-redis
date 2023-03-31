require "socket"

class RedisServer
  def initialize(port)
    @port = port
  end

  def start
    puts("Starting Redis server!")

    server = TCPServer.new(@port)

    loop do
      client = server.accept
      raw_data = client.recv(1024)
      command = parse_request(raw_data)
      response = execute_command(command)
      client.puts response
      client.close
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
