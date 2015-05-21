class ExplanationEntry::LateInterestEntry < ExplanationEntry
  ADDITIONAL_ATTRIBUTES = [:period_start, :period_end, :amount_owed, :interest_rate, :days, :label]

  def self.attributes; super + ADDITIONAL_ATTRIBUTES; end
  attr_accessor *ADDITIONAL_ATTRIBUTES

  def self.parse_entries(content)
    entries = []

    regexp = /(?<period_start>#{Explanations::DATE}) bis (?<period_end>#{Explanations::DATE}) \/ (?:(?:(?<amount_owed>#{AMOUNT}) x (?<interest_rate>#{PERCENTAGE}) x (?<days>\d+) : 365)|(?<label>[\w-]+)) #{INDENTED_AMOUNT}/
    while content.scan_until(regexp)
      period_start, period_end, amount_owed, interest_rate, days, label, indentation, amount = content.matched.match(regexp)[1..-1]

      entries << new(
        period_start: period_start,
        period_end: period_end,
        label: label,
        amount_owed: amount_owed,
        interest_rate: interest_rate,
        days: days,
        amount: convert_indented_amount(amount, content.matched.length)
      )
    end

    entries
  end

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
