require "rails_helper"

RSpec.describe "Results for PDF 1" do
  let(:file) { "1.pdf" }

  include_examples "general data"

  @parts = %w[balance_from_previous_quarters prepayment]
  include_examples "parts"
end
