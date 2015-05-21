class ExplanationEntry::CollectionExpenseEntry < ExplanationEntry
  string_attributes :label

  def self.parse_entries(content)
    entries = []

    # are these all?
    labels = ["Mahngebühr", "Barauslagen bei Exekution", "Exekutionsgebühren", "Pauschalgebühren für Exekutionsantrag"]

    regexp = /(?<date>#{Explanations::DATE}) (?<label>(?:#{labels.join("|")})) #{INDENTED_AMOUNT}/
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
