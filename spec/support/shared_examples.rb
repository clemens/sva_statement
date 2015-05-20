RSpec.shared_examples "general data" do
  let(:values) { YAML.load_file(fixture(file.gsub(".pdf", ".yml"))) }

  subject(:statement) { Statement.from_file(fixture(file)) }

  it "reads the name" do
    expect(statement.name).to eq values["name"]
  end

  it "reads the social security number" do
    expect(statement.social_security_number).to eq values["social_security_number"]
  end

  it "reads the quarter and year" do
    expect(statement.year).to eq values["year"]
    expect(statement.quarter).to eq values["quarter"]
  end

  describe "Account balance overview" do
    context "balance from previous quarters" do
      let(:scoped_values) { values["account_balance_overview"]["balance_from_previous_quarters"] }

      it "reads the amount" do
        expect(statement.balance_from_previous_quarters_amount).to eq scoped_values["amount"]
      end

      it "reads the entries" do
        entries = scoped_values["entries"].map { |attributes| Entry.new(attributes) }

        expect(statement.balance_from_previous_quarters_entries).to eq entries
      end
    end

    context "prepayment for the current quarter" do
      let(:scoped_values) { values["account_balance_overview"]["prepayment"] }

      it "reads the amount" do
        expect(statement.prepayment_amount).to eq scoped_values["amount"]
      end

      it "reads the entries" do
        entries = scoped_values["entries"].map { |attributes| Entry.new(attributes) }

        expect(statement.prepayment_entries).to eq entries
      end
    end
  end
end
