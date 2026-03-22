class Item
  attr_reader :quantity, :imported, :name, :unit_price

  def initialize(quantity:, imported:, name:, unit_price:)
    @quantity   = quantity
    @imported   = imported
    @name       = name
    @unit_price = unit_price
  end

  def imported?
    @imported
  end
end
