require "socket"

class RedisServer
  def initialize(port)
    @port = port
  end

  def start
    puts("Starting Redis server!")

    server = TCPServer.new(@port)
    client = server.accept

    loop do
      begin
        if client.closed?
          puts "Client closed the connection"
          break
        end

        raw_data = client.recv(1024)
        command = parse_request(raw_data)
        response = execute_command(command)
        client.puts response
      rescue Errno::ECONNRESET
        puts "Client closed the connection"
        client.close
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
