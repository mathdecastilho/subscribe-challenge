require_relative "lib/parsers/string_parser"
require_relative "lib/formatters/string_formatter"
require_relative "lib/taxes/taxes"

class App
  def initialize(parser: Parser::String.new, formatter: Formatter::String.new, taxes_class: Taxes)
    @parser      = parser
    @formatter   = formatter
    @taxes_class = taxes_class
  end

  def call(input)
    items = @parser.call(input)
    taxes = @taxes_class.new(items)
    @formatter.call(items, taxes)
  end
end

if __FILE__ == $PROGRAM_NAME
  puts App.new.call(ARGV[0].to_s)
end
