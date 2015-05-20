class ExplanationEntry::PreviousQuartersBalanceEntry < ExplanationEntry
  def self.attributes; super + [:label]; end
  attr_accessor :label
end
