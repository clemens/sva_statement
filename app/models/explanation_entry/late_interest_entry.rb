class ExplanationEntry::LateInterestEntry < ExplanationEntry
  string_attributes :label
  date_attributes :period_start, :period_end
  number_attributes :amount_owed, :interest_rate
  integer_attributes :days

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
end
