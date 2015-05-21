class ExplanationEntry::LateInterestEntry < ExplanationEntry
  attribute :label, String
  attribute :period, Period
  attribute :amount_owed, Decimal
  attribute :interest_rate, Decimal
  attribute :days, Integer

  def self.parse_entries(content)
    entries = []

    regexp = /(?<period_start>#{Explanations::DATE}) bis (?<period_end>#{Explanations::DATE}) \/ (?:(?:(?<amount_owed>#{AMOUNT}) x (?<interest_rate>#{PERCENTAGE}) x (?<days>\d+) : 365)|(?<label>[\w-]+)) #{INDENTED_AMOUNT}/
    while content.scan_until(regexp)
      period_start, period_end, amount_owed, interest_rate, days, label, indentation, amount = content.matched.match(regexp)[1..-1]

      entries << new(
        period: Period.new(start_date: period_start, end_date: period_end),
        label: label,
        amount_owed: amount_owed ? convert_number(amount_owed) : nil,
        interest_rate: interest_rate ? convert_number(interest_rate) : nil,
        days: days,
        amount: convert_indented_amount(amount, content.matched.length)
      )
    end

    entries
  end
end
