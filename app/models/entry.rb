class Entry
  include Numbers

  def self.attributes; [:amount]; end
  attr_accessor *attributes # FIXME repetition

  def initialize(attributes = {})
    attributes.symbolize_keys!

    self.class.attributes.each do |attribute|
      raise ArgumentError unless respond_to?(attribute)

      send("#{attribute}=", attributes[attribute])
    end
  end

  def amount=(amount)
    @amount = BigDecimal.new(amount.to_s) if amount
  end

  def ==(other)
    values = []
    value = self.class.attributes.all? do |attribute|
      values << [attribute, send(attribute), other.send(attribute), send(attribute) == other.send(attribute)]
      send(attribute) == other.send(attribute)
    end
    values.insert(0, value)
    # p values
    # puts '-' * 100
    value
  end
end
