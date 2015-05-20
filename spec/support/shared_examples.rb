RSpec.shared_examples "general data" do
  subject(:statement) { Statement.from_file(fixture(file)) }

  let(:values) { YAML.load_file(fixture(file.gsub(".pdf", ".yml"))) }

  describe "general data" do
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
          entries = scoped_values["entries"].map { |attributes| SummaryEntry.new(attributes) }

          expect(statement.balance_from_previous_quarters_entries).to eq entries
        end
      end

      context "prepayment for the current quarter" do
        let(:scoped_values) { values["account_balance_overview"]["prepayment"] }

        it "reads the amount" do
          expect(statement.prepayment_amount).to eq scoped_values["amount"]
        end

        it "reads the entries" do
          entries = scoped_values["entries"].map { |attributes| SummaryEntry.new(attributes) }

          expect(statement.prepayment_entries).to eq entries
        end
      end
    end
  end
end

RSpec.shared_examples "part: balance previous quarters" do
  describe "part: balance previous quarters" do
    it "reads the balance from the previous quarter" do
      expected_values = values["explanations"]["parts"].detect { |part| part["type"] == "balance_from_previous_quarters" }

      part = statement.explanations.parts.detect { |part| part.type == "balance_from_previous_quarters" }

      expect(part.label).to eq expected_values["label"]
      expected_values["entries"].each do |attributes|
        expected_entry = ExplanationEntry::PreviousQuartersBalanceEntry.new(attributes)
        entry = part.entries.detect { |entry| entry == expected_entry }

        expect(entry).to_not be_nil
      end
    end
  end
end

RSpec.shared_examples "part: payments" do
  describe "part: payments" do
    it "reads the payments" do
      expected_values = values["explanations"]["parts"].detect { |part| part["type"] == "payments" }
      part = statement.explanations.parts.detect { |part| part.type == "payments" }

      expect(part.label).to eq expected_values["label"]
      expected_values["entries"].each do |attributes|
        expected_entry = ExplanationEntry::PaymentEntry.new(attributes)
        entry = part.entries.detect { |entry| entry == expected_entry }

        expect(entry).to_not be_nil
      end
    end
  end
end

RSpec.shared_examples "part: late interest" do
  describe "part: late interest" do
    it "reads late interest entries" do
      expected_values = values["explanations"]["parts"].detect { |part| part["type"] == "late_interest" }
      part = statement.explanations.parts.detect { |part| part.type == "late_interest" }

      expect(part.label).to eq expected_values["label"]
      expected_values["entries"].each do |attributes|
        expected_entry = ExplanationEntry::LateInterestEntry.new(attributes)
        entry = part.entries.detect { |entry| entry == expected_entry }

        expect(entry).to_not be_nil
      end
    end
  end
end
