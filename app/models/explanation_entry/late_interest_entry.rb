class ExplanationEntry::LateInterestEntry < ExplanationEntry
  ADDITIONAL_ATTRIBUTES = [:period_start, :period_end, :amount_owed, :interest_rate, :days, :label]

  def self.attributes; super + ADDITIONAL_ATTRIBUTES; end
  attr_accessor *ADDITIONAL_ATTRIBUTES

  def period_start=(period_start)
    @period_start = if period_start.present?
      period_start.respond_to?(:strftime) ? period_start : Date.parse(period_start)
    end
  end

  def period_end=(period_end)
    @period_end = if period_end.present?
      period_end.respond_to?(:strftime) ? period_end : Date.parse(period_end)
    end
  end

  def amount_owed=(amount_owed)
    @amount_owed = convert_number(amount_owed)
  end

  def interest_rate=(interest_rate)
    @interest_rate = convert_number(interest_rate)
  end

  def days=(days)
    @days = days.try(:to_i)
  end
end
