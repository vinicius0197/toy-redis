class RESPParser
  attr_accessor :encoded_data

  def initialize(encoded_data)
    @encoded_data = encoded_data
  end

  def decode
    arguments = {}
    _, command, *key_value_pairs = encoded_data.split("\r\n").reject do |item|
      item.start_with?("$")
    end

    key_value_pairs.each_slice(2) do |key, value|
      arguments[key] = value
    end

    [command.downcase, arguments]
  end
end
