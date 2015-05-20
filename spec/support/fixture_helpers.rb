module FixtureHelpers
  def fixture(filename)
    Rails.root.join("spec/fixtures/#{filename}")
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
