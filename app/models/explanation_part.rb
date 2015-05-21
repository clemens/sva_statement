# TODO move parse_xxx methods to their respective classes

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
    "Mahnkosten" => "collection_expenses"
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
    when /(Saldovortrag)/, /(Vorschreibung)/, /(Verzugszinsen)/ then TYPES[$~[1]]
    when /Mahn/ then TYPES["Mahnkosten"]
    else
      TYPES[@label] ? TYPES[@label] : raise("unknown type for label: #{@label}")
    end

    send("parse_#{type}", content) if respond_to?("parse_#{type}")
  end

  def parse_balance_from_previous_quarters(content)
    date = content.string.match(/#{Explanations::DATE}/)
    content.scan_until(/letzter Vorschreibebetrag/)
    label = content.matched
    indentation, amount = content.rest.match(/#{INDENTED_AMOUNT}/)[1,2]

    @entries = [
      ExplanationEntry::BalanceFromPreviousQuarterEntry.new(
        label: label,
        amount: convert_indented_amount(amount, content.matched.length)
      )
    ]
  end

  def parse_payments(content)
    @entries = []

    regexp = /(?<label>#{Explanations::DATE} Zahlung)#{INDENTED_AMOUNT}/
    while content.scan_until(regexp)
      label, indentation, amount = content.matched.match(regexp)[1..-1]

      @entries << ExplanationEntry::PaymentEntry.new(
        label: label,
        amount: convert_indented_amount(amount, content.matched.length)
      )
    end
  end

  def parse_late_interest(content)
    @entries = []

    regexp = /(?<period_start>#{Explanations::DATE}) bis (?<period_end>#{Explanations::DATE}) \/ (?:(?:(?<amount_owed>#{AMOUNT}) x (?<interest_rate>#{PERCENTAGE}) x (?<days>\d+) : 365)|(?<label>[\w-]+)) #{INDENTED_AMOUNT}/
    while content.scan_until(regexp)
      period_start, period_end, amount_owed, interest_rate, days, label, indentation, amount = content.matched.match(regexp)[1..-1]

      @entries << ExplanationEntry::LateInterestEntry.new(
        period_start: period_start,
        period_end: period_end,
        label: label,
        amount_owed: amount_owed,
        interest_rate: interest_rate,
        days: days,
        amount: convert_indented_amount(amount, content.matched.length)
      )
    end
  end

  def parse_collection_expenses(content)
    @entries = []

    # are these all?
    labels = ["Mahngebühr", "Barauslagen bei Exekution", "Exekutionsgebühren", "Pauschalgebühren für Exekutionsantrag"]

    regexp = /(?<date>#{Explanations::DATE}) (?<label>(?:#{labels.join("|")})) #{INDENTED_AMOUNT}/
    while content.scan_until(regexp)
      date, label, indentation, amount = content.matched.match(regexp)[1..-1]

      @entries << ExplanationEntry::CollectionExpenseEntry.new(
        date: date,
        label: label,
        amount: convert_indented_amount(amount, content.matched.length)
      )
    end
  end
end
