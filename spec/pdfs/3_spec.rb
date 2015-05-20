require "rails_helper"

RSpec.describe "Results for PDF 3" do
  let(:file) { "3.pdf" }

  include_examples "general data"
  include_examples "part: balance previous quarters"
  include_examples "part: late interest"
end
