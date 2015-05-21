class ExplanationEntry::PaymentEntry < ExplanationEntry
  def self.attributes; super + [:label]; end
  attr_accessor :label

  def self.parse_entries(content)
    entries = []

    regexp = /(?<label>#{Explanations::DATE} Zahlung)#{INDENTED_AMOUNT}/
    while content.scan_until(regexp)
      label, indentation, amount = content.matched.match(regexp)[1..-1]

      entries << new(
        label: label,
        amount: convert_indented_amount(amount, content.matched.length)
      )
    end

    entries
  end
end
