require "rails_helper"

RSpec.describe "Results for PDF 5" do
  let(:file) { "5.pdf" }

  include_examples "general data"
  include_examples "part: balance previous quarters"
  include_examples "part: payments"
end
