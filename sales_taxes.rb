class SalesTaxes
  def call(input)
    input
  end
end

if __FILE__ == $PROGRAM_NAME
  puts SalesTaxes.new.call(ARGV[0].to_s)
end
