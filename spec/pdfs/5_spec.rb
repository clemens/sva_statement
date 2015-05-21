require "rails_helper"

RSpec.describe "Results for PDF 5" do
  let(:file) { "5.pdf" }

  include_examples "general data"

  @parts = %w[balance_from_previous_quarters payments prepayment]
  include_examples "parts"
end
