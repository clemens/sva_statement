class SummaryEntry < Entry
  def self.attributes; super + [:label]; end
  attr_accessor :label
end
