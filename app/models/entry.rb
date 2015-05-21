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
    self.class.attributes.all? do |attribute|
      send(attribute) == other.send(attribute)
    end
  end
end
