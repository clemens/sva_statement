class Entry
  include Numbers
  include Virtus.model

  attribute :amount, Decimal

  def ==(other)
    self.class.attribute_set.all? do |attribute|
      send(attribute.name) == other.send(attribute.name)
    end
  end
end
