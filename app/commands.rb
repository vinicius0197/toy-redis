# This module contains all the commands that can be executed by the server
module Commands
  DEFAULT_EXPIRY_VALUE = 0
  def ping_command
    "+PONG\r\n"
  end

  def echo_command(arguments)
    echo_string = arguments.keys.first
    "$#{echo_string.bytesize}\r\n#{echo_string}\r\n"
  end

  def set_command(arguments, data_store)
    key = arguments.keys.first
    value = arguments[key]
    expiry = DEFAULT_EXPIRY_VALUE

    if arguments["EX"]
      expiry = Time.now.to_i + arguments["EX"].to_i
    end

    data_store[key] = { value: value, expiry: expiry }
    data_store
  end

  def get_command(arguments, data_store)
    key = arguments.keys.first

    if data_store[key].nil?
      return "$-1\r\n"
    end

    value = data_store[key][:value]
    "$#{value.bytesize}\r\n#{value}\r\n"
  end

  def error_command(command)
    "-Unknown command #{command}\r\n"
  end
end
