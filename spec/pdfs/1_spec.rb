require "rails_helper"

RSpec.describe "Results for PDF 1" do
  let(:file) { "1.pdf" }

  include_examples "general data"
  include_examples "part: balance previous quarters"
end
