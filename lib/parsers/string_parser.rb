require_relative "parser"
require_relative "../item"

module Parser
  class String < Base
    # Matches: <quantity> [imported] <name> at <price>
    # The word "imported" is optional and may appear anywhere before "at".
    LINE_PATTERN = /\A(\d+) (imported )?(.+?) at (\d+\.\d{2})\z/

    def call(input)
      input.split("\n").map { |line| parse_line(line) }
    end

    private

    def parse_line(line)
      match = line.match(LINE_PATTERN)
      raise ArgumentError, "Invalid item line: #{line.inspect}" unless match

      Item.new(
        quantity:   match[1].to_i,
        imported:   !match[2].nil?,
        name:       match[3],
        unit_price: match[4].to_f
      )
    end
  end
end
