# FIXME unify handling for dates and numbers

class ExplanationEntry::PrepaymentEntry < ExplanationEntry
  ADDITIONAL_ATTRIBUTES = [:label, :period_start, :period_end, :assessment_basis, :rate, :monthly_amount]

  def self.attributes; super + ADDITIONAL_ATTRIBUTES; end
  attr_accessor *ADDITIONAL_ATTRIBUTES

  def self.elements
    ["Unfallversicherung (UV)", "Pensionsversicherung (PV)", "Krankenversicherung (KV)", "Selbständigenvorsorge (SeVo)"]
  end

  def self.labels
    ["UV-Beitrag ASVG", "PV-Beitrag GSVG", "KV-Beitrag", "KV-Zusatzversicherungsbeitrag", "SeVo-Beitrag PFLICHT"]
  end

  def self.parse_entries(content)
    entries = []

    found_elements = content.string.scan(/#{elements.map { |element| Regexp.escape(element) }.join("|")}/)

    # jump to the first element
    content.skip_until(/#{Regexp.escape(found_elements.first)}/)

    element_contents = found_elements[1..-1].map do |element|
      content.scan_until(/#{Regexp.escape(element)}/)
    end + [content.rest]

    element_contents.each do |element_content|
      content = StringScanner.new(element_content)

      label_regexp = /(?<label>#{labels.join("|")})\s{2,}/ # look for at least two spaces after the label so we don't match inside a paragraph of text
      period_regexp = /(?<period_start>#{Explanations::DATE}) bis (?<period_end>#{Explanations::DATE})/
      amount_line_regexp = /(?:(?:(?<assessment_basis>#{AMOUNT}) x (?<rate>#{PERCENTAGE}))|Monatsbeitrag) = (?<monthly_amount>#{AMOUNT}) x \d+ Monate? #{INDENTED_AMOUNT}/

      # always scan until the next label, then scan for all the attributes
      while content.scan_until(label_regexp)
        label = content.matched.strip
        content.scan_until(period_regexp)
        period_start, period_end = content.matched.match(period_regexp)[1..-1]
        content.scan_until(amount_line_regexp)
        assessment_basis, rate, monthly_amount, indentation, amount = content.matched.match(amount_line_regexp)[1..-1]
        last_line_length = content.matched.length

        entries << new(
          label: label,
          period_start: period_start,
          period_end: period_end,
          assessment_basis: assessment_basis,
          rate: rate,
          monthly_amount: monthly_amount,
          amount: convert_indented_amount(amount, last_line_length)
        )
      end
    end

    entries
  end

  def period_start=(period_start)
    @period_start = if period_start.present?
      period_start.respond_to?(:strftime) ? period_start : Date.parse(period_start)
    end
  end

  def period_end=(period_end)
    @period_end = if period_end.present?
      period_end.respond_to?(:strftime) ? period_end : Date.parse(period_end)
    end
  end

  def assessment_basis=(assessment_basis)
    @assessment_basis = convert_number(assessment_basis)
  end

  def rate=(rate)
    @rate = convert_number(rate)
  end

  def monthly_amount=(monthly_amount)
    @monthly_amount = convert_number(monthly_amount)
  end
end
