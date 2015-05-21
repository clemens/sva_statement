require "rails_helper"

RSpec.describe "Results for PDF 4" do
  let(:file) { "4.pdf" }

  include_examples "general data"
  include_examples "part: balance previous quarters"
  include_examples "part: payments"
  include_examples "part: late interest"
  include_examples "part: collection expenses"
end
