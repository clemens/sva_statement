module Numbers
  AMOUNT = "(?:\\d{1,3}\\.)*\\d{1,3},\\d{2}"
  PERCENTAGE = "(?:\\d{1,2},\\d{2}) %"
  ENTRY_REGEXP = /(?<entry_text>#{["Saldovortrag vom \\d{1,2}\.\\d{1,2}.\\d{4}", "Vorschreibung \\d. Quartal \\d{4}", "Kostenanteile", "Berichtigung \\d{4}", "Geldleistungen", "Mahn-/Exekutionskosten", "Verzugszinsen", "Mahnkosten", "Zahlungen"].join("|")})(?<indentation>\s+)(?<amount>#{AMOUNT})/
  AMOUNT_REGEXP = /#{AMOUNT}/ # amount of any size with thousands separator and 2 decimal places
  SIGNED_AMOUNT_REGEXP = /(?:[+-])#{AMOUNT}/ # like above, but signed
  PERCENTAGE_REGEXP = /#{PERCENTAGE}/ # percentages with 2 places and 1 or 2 decimal places

  def convert_number(number)
    return 0 if number.nil?

    BigDecimal.new(number.gsub(".", "").gsub(",", "."))
  end

  def convert_indented_amount(amount, indentation, indentation_threshold)
    return 0 if amount.nil?

    amount = convert_number(amount)
    amount = -amount if indentation.length < indentation_threshold
    amount
  end

  def read_amount(text, start_index, end_index)
    text.slice(start_index..end_index).match(AMOUNT_REGEXP)[0]
  end

  def read_signed_amount(text)
    text.match(SIGNED_AMOUNT_REGEXP)[0]
  end

  def read_percentage(text, start_index, end_index)
    text.slice(start_index..end_index).match(PERCENTAGE_REGEXP)[1]
  end
end
