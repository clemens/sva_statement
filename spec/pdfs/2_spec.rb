require "rails_helper"

RSpec.describe "Results for PDF 2" do
  let(:file) { "2.pdf" }

  include_examples "general data"
  include_examples "part: balance previous quarters"
  include_examples "part: payments"
  include_examples "part: late interest"
end
