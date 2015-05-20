class Entry
  attr_accessor :label, :amount

  def initialize(attributes = {})
    attributes.symbolize_keys.slice(:label, :amount).each do |attribute, value|
      raise ArgumentError unless respond_to?(attribute)

      send("#{attribute}=", value)
    end
  end

  def amount=(amount)
    @amount = BigDecimal.new(amount.to_s) if amount
  end

  def ==(other)
    [label, amount] == [other.label, other.amount]
  end
end
