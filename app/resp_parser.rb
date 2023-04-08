class RESPParser
  attr_accessor :encoded_data

  def initialize(encoded_data)
    @encoded_data = encoded_data
  end

  def decode
    arguments_size, command, *arguments = encoded_data.split("\r\n").reject do |item|
      item.start_with?("$")
    end

    [command.downcase, arguments]
  end
end
