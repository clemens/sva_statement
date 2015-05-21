require "rails_helper"

RSpec.describe "Results for PDF 2" do
  let(:file) { "2.pdf" }

  include_examples "general data"

  @parts = %w[balance_from_previous_quarters payments late_interest prepayment]
  include_examples "parts"
end
