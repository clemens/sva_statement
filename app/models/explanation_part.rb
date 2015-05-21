class ExplanationPart
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
    else TYPES[@label]
    end

    begin
      @entries = ExplanationEntry.const_get("#{type.classify}Entry").parse_entries(content)
    rescue NameError
      # puts "Unknown type for label: #{@label}"
      @entries = []
    end
  end
end
