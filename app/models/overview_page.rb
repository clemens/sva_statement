class OverviewPage
  include Numbers

  def initialize(contents)
    @contents = contents
  end

  def balance_from_previous_quarters_amount(convert = true)
    slice = @contents.slice(@contents.index("Offener Betrag aus Vorquartalen")..@contents.index("Vorschreibebetrag"))
    amount = read_signed_amount(slice)
    convert ? convert_number(amount) : amount
  end

  def balance_from_previous_quarters_entries
    start_index = @contents.index("Buchungsübersicht")
    end_index = @contents.index(balance_from_previous_quarters_amount(false), @contents.index("Buchungsübersicht"))

    read_entries(@contents.slice(start_index..end_index))
  end

  def prepayment_amount(convert = true)
    slice = @contents.slice(@contents.index("Vorschreibebetrag")..@contents.index("Gesamtsumme"))
    amount = read_signed_amount(slice)
    convert ? convert_number(amount) : amount
  end

  def prepayment_entries
    start_index = @contents.index(balance_from_previous_quarters_amount(false), @contents.index("Buchungsübersicht"))
    end_index = @contents.index(prepayment_amount(false), @contents.index("Buchungsübersicht"))

    read_entries(@contents.slice(start_index..end_index))
  end

  def quarter
    quarter_and_year[:quarter].to_i
  end

  def year
    quarter_and_year[:year].to_i
  end

  private

  def read_entries(contents)
    contents.scan(ENTRY_REGEXP).map do |entry_text, indentation, amount|
      SummaryEntry.new(
        label: entry_text,
        amount: convert_indented_amount(amount, "#{entry_text}#{indentation}#{amount}".length)
      )
    end
  end

  def quarter_and_year
    @contents.match(/Vorschreibebetrag im (?<quarter>\d)\. Quartal (?<year>\d{4})/)
  end

end
