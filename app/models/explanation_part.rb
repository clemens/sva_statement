class ExplanationPart
  include Numbers

  PARTS = ["Saldovortrag vom #{Explanations::DATE}", "Zahlungen", "Berichtigung", "Verzugszinsen \\(VZ\\)", "Mahnkosten", "Mahn-\\/Exekutionskosten", "Vorschreibung \\d\\. Quartal \\d{4}"]
  PARTS_REGEXP = /(?<abschnitt>#{PARTS.join("|")})/

  TYPES = {
    "Saldovortrag" => "balance_from_previous_quarters",
    "Zahlungen" => "payments",
    "Vorschreibung" => "prepayment",
    "Berichtigung" => "adjustment",
    "Verzugszinsen" => "late_interest",
    "Mahnkosten" => "collection_expensions",
    "Mahn-/Exekutionskosten" => "distraint_expenses"
  }

  attr_reader :type, :label, :entries

  def initialize(content)
    @content = content.strip
    parse
  end

  def parse
    content = StringScanner.new(@content)

    @label = content.scan(PARTS_REGEXP)

    @type = case @label
    when /(Saldovortrag)/, /(Vorschreibung)/ then TYPES[$~[1]]
    else TYPES[@label]
    end

    send("parse_#{type}", content) if respond_to?("parse_#{type}")
  end

  def parse_balance_from_previous_quarters(content)
    date = content.string.match(/#{Explanations::DATE}/)
    content.scan_until(/letzter Vorschreibebetrag/)
    label = content.matched
    indentation, amount = content.rest.match(/#{INDENTED_AMOUNT}/)[1,2]

    @entries = [
      ExplanationEntry.new(
        label: label,
        amount: convert_indented_amount(amount, indentation, ExplanationEntry::INDENTATION_THRESHOLD)
      )
    ]
  end

  def parse_payments(content)
    @entries = []

    regexp = /(?<label>#{Explanations::DATE} Zahlung)#{INDENTED_AMOUNT}/
    while content.scan_until(regexp)
      label, indentation, amount = content.matched.match(regexp)[1..-1]

      @entries << ExplanationEntry.new(
        label: label,
        amount: convert_indented_amount(amount, indentation, ExplanationEntry::INDENTATION_THRESHOLD)
      )
    end
  end
end
