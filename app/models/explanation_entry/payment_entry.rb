class ExplanationEntry::PaymentEntry < ExplanationEntry
  attribute :label, String
  attribute :date, Date

  def self.parse_entries(content)
    entries = []

    regexp = /(?<date>#{Explanations::DATE})\s(?<label>Zahlung)#{INDENTED_AMOUNT}/
    while content.scan_until(regexp)
      date, label, indentation, amount = content.matched.match(regexp)[1..-1]

      entries << new(
        date: date,
        label: label,
        amount: convert_indented_amount(amount, content.matched.length)
      )
    end

    entries
  end
end
