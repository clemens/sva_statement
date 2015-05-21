class ExplanationEntry::BalanceFromPreviousQuarterEntry < ExplanationEntry
  string_attributes :label

  def self.parse_entries(content)
    date = content.string.match(/#{Explanations::DATE}/)
    content.scan_until(/letzter Vorschreibebetrag/)
    label = content.matched
    indentation, amount = content.rest.match(/#{INDENTED_AMOUNT}/)[1,2]

    [new(label: label, amount: convert_indented_amount(amount, content.matched.length))]
  end
end
