class ExplanationEntry::CollectionExpensesEntry < ExplanationEntry
  def self.attributes; super + [:label]; end
  attr_accessor :label
end
