require "rails_helper"

RSpec.describe "Results for PDF 3" do
  let(:file) { "3.pdf" }

  include_examples "general data"

  @parts = %w[balance_from_previous_quarters late_interest collection_expenses prepayment]
  include_examples "parts"
end
