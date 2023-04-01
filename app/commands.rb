# This module contains all the commands that can be executed by the server
module Commands
  def ping_command
    "+PONG\r\n"
  end

  def error_command(command)
    "-Unknown command #{command}\r\n"
  end
end
