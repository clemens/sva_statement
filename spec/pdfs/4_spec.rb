require "rails_helper"

RSpec.describe "Results for PDF 4" do
  let(:file) { "4.pdf" }

  include_examples "general data"

  @parts = %w[balance_from_previous_quarters payments late_interest collection_expenses]
  include_examples "parts"
end
