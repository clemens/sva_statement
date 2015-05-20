class Statement
  extend Forwardable

  def_delegators :@overview_page,
    :year, :quarter,
    :balance_from_previous_quarters_amount, :balance_from_previous_quarters_entries,
    :prepayment_amount, :prepayment_entries

  def_delegators :@explanations,
    :name, :social_security_number

  attr_reader :explanations

  def self.from_file(pdf)
    output_filename = Rails.root.join("tmp", File.basename(pdf.to_s, ".pdf") + ".txt")
    `pdftotext -enc UTF-8 -table #{pdf} #{output_filename}`

    new(Pathname.new(output_filename))
  end

  def initialize(file)
    contents = file.read

    overview_page_text = contents.slice(0..contents.index("$$$new_sheet$$$"))
    @overview_page = OverviewPage.new(overview_page_text)

    # FIXME explanations part should end with the last amount found in the overview
    explanations_text = contents.slice(contents.slice(0..contents.index("Erklärungen zum Kontoauszug vom")).rindex("$$$new_sheet$$$")..contents.index("Zahlungseingänge berücksichtigt bis"))
    @explanations = Explanations.new(explanations_text)
  end
end
