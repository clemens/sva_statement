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

RSpec.shared_examples "parts" do
  @parts.each do |part_identifier|
    describe "part: #{part_identifier}" do
      it "reads the #{part_identifier} entries" do
        expected_parts_values = values["explanations"]["parts"].select { |part| part["type"] == part_identifier }

        expected_parts_values.each do |expected_part_values|
          part = statement.explanations.parts.detect do |part|
            part.type == part_identifier &&
            part.label == expected_part_values["label"] &&
            expected_part_values["entries"].all? { |attributes|
              if attributes.slice("period_start", "period_end").size == 2
                attributes[:period] = Period.new(start_date: attributes.delete("period_start"), end_date: attributes.delete("period_end"))
              end

              expected_entry = ExplanationEntry.const_get("#{part_identifier.singularize.camelize}Entry").new(attributes)
              entry = part.entries.detect { |entry| entry == expected_entry }
            }
          end

          expect(part).to_not be_nil
        end
      end
    end
  end
end
