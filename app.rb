require_relative "lib/parsers/string_parser"
require_relative "lib/formatters/string_formatter"

class App
  def initialize(parser: Parser::String.new, formatter: Formatter::String.new)
    @parser    = parser
    @formatter = formatter
  end

  def call(input)
    items = @parser.call(input)
    @formatter.call(items)
  end
end

if __FILE__ == $PROGRAM_NAME
  puts App.new.call(ARGV[0].to_s)
end
