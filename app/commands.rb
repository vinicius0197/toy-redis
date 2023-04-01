module Commands
  def ping_command
    "+PONG\r\n"
  end

  def error_command(command)
    "-Unknown command #{command}\r\n"
  end
end
