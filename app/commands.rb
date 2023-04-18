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
    value = arguments.delete(key)
    expiry = DEFAULT_EXPIRY_VALUE

    arguments = arguments.transform_keys(&:downcase)

    if arguments["ex"]
      expiry = Time.now.to_f + arguments["ex"].to_f
    end

    if arguments["px"]
      expiry = Time.now.to_f + arguments["px"].to_f/1000
    end

    data_store[key] = { value: value, expiry: expiry }
    data_store
  end

  def get_command(arguments, data_store)
    key = arguments.keys.first

    if data_store[key].nil?
      return "$-1\r\n"
    end

    if data_store[key][:expiry] != 0 && data_store[key][:expiry] < Time.now.to_f
      return "$-1\r\n"
    end

    value = data_store[key][:value]
    "$#{value.bytesize}\r\n#{value}\r\n"
  end

  def error_command(command)
    "-Unknown command #{command}\r\n"
  end
end
