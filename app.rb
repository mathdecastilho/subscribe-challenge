require_relative "lib/parsers/string_parser"

class App
  def initialize(parser: Parser::String.new)
    @parser = parser
  end

  def call(input)
    @parser.call(input)
  end
end

if __FILE__ == $PROGRAM_NAME
  items = App.new.call(ARGV[0].to_s)
  items.each { |item| puts item.inspect }
end
