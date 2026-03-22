class Item
  # Maps each known product name (singular and plural) to its tax category.
  #
  # NOTE: This is not an ideal solution. Hardcoding product names here means
  # every new product must be manually added to this list, and matching by name
  # is brittle — a product like "chocolate perfume" would be misclassified
  # because its name contains a word that belongs to a different category.
  # A proper solution would store the category as explicit data on the product
  # (e.g. a database column or a dedicated field in the input format).
  CATEGORIES = {
    "book"                        => :book,
    "books"                       => :book,
    "box of chocolates"           => :food,
    "boxes of chocolates"         => :food,
    "chocolate bar"               => :food,
    "chocolate bars"              => :food,
    "packet of headache pills"    => :medical,
    "packets of headache pills"   => :medical
  }.freeze

  attr_reader :quantity, :imported, :name, :unit_price, :category

  def initialize(quantity:, imported:, name:, unit_price:)
    @quantity   = quantity
    @imported   = imported
    @name       = name
    @unit_price = unit_price
    @category   = CATEGORIES.fetch(name.downcase, :other)
  end

  def imported?
    @imported
  end
end
