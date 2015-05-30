require "rails_helper"

RSpec.describe "Statements API", type: :request do
  describe "GET to #parse" do
    let(:headers) { { "HTTP_ACCEPT" => "application/json" } }

    context "when given a PDF file" do
      let!(:statement) do
        params = { file: file_from(fixture("#{number}.pdf"), "application/pdf") }

        post "/statements/parse", params, headers

        expect(response).to be_success

        statement = JSON.parse(response.body)
      end

      describe "PDF 1" do
        let(:number) { 1 }

        it "evaluates the given PDF file" do
          # general data
          expect(statement["name"]).to eq "Martina Musterfrau"
          expect(statement["social_security_number"]).to eq "0001 020202"
          expect(statement["year"]).to eq 2015
          expect(statement["quarter"]).to eq 2
          expect(statement["deferred_payment_negotiated"]).to eq true

          # account balance overview
          balance_from_previous_quarters = statement["account_balance_overview"]["balance_from_previous_quarters"]
          expect(balance_from_previous_quarters["amount"]).to eq -13.44
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -13.44
          prepayment = statement["account_balance_overview"]["prepayment"]
          expect(prepayment["amount"]).to eq -46.35
          expect(prepayment["entries"][0]["label"]).to eq "Vorschreibung 2. Quartal 2015"
          expect(prepayment["entries"][0]["amount"]).to eq -473.28
          expect(prepayment["entries"][1]["label"]).to eq "Kostenanteile"
          expect(prepayment["entries"][1]["amount"]).to eq -3.57
          expect(prepayment["entries"][2]["label"]).to eq "Berichtigung 2015"
          expect(prepayment["entries"][2]["amount"]).to eq 430.50

          # explanations
          parts = statement["explanations"]["parts"]

          balance_from_previous_quarters = parts.detect { |part| part["type"] == "balance_from_previous_quarters" }
          expect(balance_from_previous_quarters["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "letzter Vorschreibebetrag"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -13.44

          # TODO period start and end
          prepayment = parts.detect { |part| part["type"] == "prepayment" }
          accident_insurance = prepayment["entries"][0]
          expect(accident_insurance["label"]).to eq "UV-Beitrag ASVG"
          expect(accident_insurance["monthly_amount"]).to eq 8.90
          expect(accident_insurance["months"]).to eq 3
          expect(accident_insurance["amount"]).to eq -26.70

          retirement_pension_insurance = prepayment["entries"][1]
          expect(retirement_pension_insurance["label"]).to eq "PV-Beitrag GSVG"
          expect(retirement_pension_insurance["assessment_basis"]).to eq 537.78
          expect(retirement_pension_insurance["rate"]).to eq 18.50
          expect(retirement_pension_insurance["monthly_amount"]).to eq 99.49
          expect(retirement_pension_insurance["months"]).to eq 3
          expect(retirement_pension_insurance["amount"]).to eq -298.47

          health_insurance = prepayment["entries"][2]
          expect(health_insurance["label"]).to eq "KV-Beitrag"
          expect(health_insurance["assessment_basis"]).to eq 537.78
          expect(health_insurance["rate"]).to eq 7.65
          expect(health_insurance["monthly_amount"]).to eq 41.14
          expect(health_insurance["months"]).to eq 3
          expect(health_insurance["amount"]).to eq -123.42

          required_sevo = prepayment["entries"][3]
          expect(required_sevo["label"]).to eq "SeVo-Beitrag PFLICHT"
          expect(required_sevo["assessment_basis"]).to eq 537.78
          expect(required_sevo["rate"]).to eq 1.53
          expect(required_sevo["monthly_amount"]).to eq 8.23
          expect(required_sevo["months"]).to eq 3
          expect(required_sevo["amount"]).to eq -24.69
        end
      end

      describe "PDF 2" do
        let(:number) { 2 }

        it "evaluates the given PDF file" do
          # general data
          expect(statement["name"]).to eq "Max Müllermann"
          expect(statement["social_security_number"]).to eq "0002 030303"
          expect(statement["year"]).to eq 2015
          expect(statement["quarter"]).to eq 2
          expect(statement["deferred_payment_negotiated"]).to eq true

          # account balance overview
          balance_from_previous_quarters = statement["account_balance_overview"]["balance_from_previous_quarters"]
          expect(balance_from_previous_quarters["amount"]).to eq -1746.19
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -2441.42
          expect(balance_from_previous_quarters["entries"][1]["label"]).to eq "Zahlungen"
          expect(balance_from_previous_quarters["entries"][1]["amount"]).to eq 300.00
          expect(balance_from_previous_quarters["entries"][2]["label"]).to eq "Berichtigung 2015"
          expect(balance_from_previous_quarters["entries"][2]["amount"]).to eq 409.92
          expect(balance_from_previous_quarters["entries"][3]["label"]).to eq "Verzugszinsen"
          expect(balance_from_previous_quarters["entries"][3]["amount"]).to eq -14.69
          prepayment = statement["account_balance_overview"]["prepayment"]
          expect(prepayment["amount"]).to eq -1849.74
          expect(prepayment["entries"][0]["label"]).to eq "Vorschreibung 2. Quartal 2015"
          expect(prepayment["entries"][0]["amount"]).to eq -1272.30
          expect(prepayment["entries"][1]["label"]).to eq "Berichtigung 2012"
          expect(prepayment["entries"][1]["amount"]).to eq -577.44

          # explanations
          parts = statement["explanations"]["parts"]

          balance_from_previous_quarters = parts.detect { |part| part["type"] == "balance_from_previous_quarters" }
          expect(balance_from_previous_quarters["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "letzter Vorschreibebetrag"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -2441.42

          payments = parts.detect { |part| part["type"] == "payments" }
          expect(payments["label"]).to eq "Zahlungen"
          expect(payments["entries"][0]["date"]).to eq "2015-03-24"
          expect(payments["entries"][0]["label"]).to eq "Zahlung"
          expect(payments["entries"][0]["amount"]).to eq 300.00

          # TODO period start and end
          late_interest = parts.detect { |part| part["type"] == "late_interest" }
          expect(late_interest["label"]).to eq "Verzugszinsen (VZ)"
          expect(late_interest["entries"][0]["amount_owed"]).to eq 127.49
          expect(late_interest["entries"][0]["interest_rate"]).to eq 7.88
          expect(late_interest["entries"][0]["days"]).to eq 54
          expect(late_interest["entries"][0]["amount"]).to eq -1.49
          expect(late_interest["entries"][1]["amount_owed"]).to eq 1908.38
          expect(late_interest["entries"][1]["interest_rate"]).to eq 7.88
          expect(late_interest["entries"][1]["days"]).to eq 5
          expect(late_interest["entries"][1]["amount"]).to eq -2.06
          expect(late_interest["entries"][2]["amount_owed"]).to eq 1612.92
          expect(late_interest["entries"][2]["interest_rate"]).to eq 7.88
          expect(late_interest["entries"][2]["days"]).to eq 32
          expect(late_interest["entries"][2]["amount"]).to eq -11.14

          # TODO period start and end
          prepayment = parts.detect { |part| part["type"] == "prepayment" }
          accident_insurance = prepayment["entries"][0]
          expect(accident_insurance["label"]).to eq "UV-Beitrag ASVG"
          expect(accident_insurance["monthly_amount"]).to eq 8.90
          expect(accident_insurance["months"]).to eq 3
          expect(accident_insurance["amount"]).to eq -26.70

          retirement_pension_insurance = prepayment["entries"][1]
          expect(retirement_pension_insurance["label"]).to eq "PV-Beitrag GSVG"
          expect(retirement_pension_insurance["assessment_basis"]).to eq 1500.00
          expect(retirement_pension_insurance["rate"]).to eq 18.50
          expect(retirement_pension_insurance["monthly_amount"]).to eq 277.50
          expect(retirement_pension_insurance["months"]).to eq 3
          expect(retirement_pension_insurance["amount"]).to eq -832.50

          health_insurance = prepayment["entries"][2]
          expect(health_insurance["label"]).to eq "KV-Beitrag"
          expect(health_insurance["assessment_basis"]).to eq 1500.00
          expect(health_insurance["rate"]).to eq 7.65
          expect(health_insurance["monthly_amount"]).to eq 114.75
          expect(health_insurance["months"]).to eq 3
          expect(health_insurance["amount"]).to eq -344.25

          required_sevo = prepayment["entries"][3]
          expect(required_sevo["label"]).to eq "SeVo-Beitrag PFLICHT"
          expect(required_sevo["assessment_basis"]).to eq 1500.00
          expect(required_sevo["rate"]).to eq 1.53
          expect(required_sevo["monthly_amount"]).to eq 22.95
          expect(required_sevo["months"]).to eq 3
          expect(required_sevo["amount"]).to eq -68.85
        end
      end

      describe "PDF 3" do
        let(:number) { 3 }

        it "evaluates the given PDF file (3.pdf)" do
          # general data
          expect(statement["name"]).to eq "Herbert Traunsteiner"
          expect(statement["social_security_number"]).to eq "0003 040404"
          expect(statement["year"]).to eq 2015
          expect(statement["quarter"]).to eq 2
          expect(statement["deferred_payment_negotiated"]).to eq false

          # account balance overview
          balance_from_previous_quarters = statement["account_balance_overview"]["balance_from_previous_quarters"]
          expect(balance_from_previous_quarters["amount"]).to eq -4110.19
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -9731.68
          expect(balance_from_previous_quarters["entries"][1]["label"]).to eq "Geldleistungen"
          expect(balance_from_previous_quarters["entries"][1]["amount"]).to eq 19.20
          expect(balance_from_previous_quarters["entries"][2]["label"]).to eq "Berichtigung 2012"
          expect(balance_from_previous_quarters["entries"][2]["amount"]).to eq 2372.04
          expect(balance_from_previous_quarters["entries"][3]["label"]).to eq "Berichtigung 2015"
          expect(balance_from_previous_quarters["entries"][3]["amount"]).to eq 3382.77
          expect(balance_from_previous_quarters["entries"][4]["label"]).to eq "Verzugszinsen"
          expect(balance_from_previous_quarters["entries"][4]["amount"]).to eq -53.33
          expect(balance_from_previous_quarters["entries"][5]["label"]).to eq "Mahn-/Exekutionskosten"
          expect(balance_from_previous_quarters["entries"][5]["amount"]).to eq -99.19
          prepayment = statement["account_balance_overview"]["prepayment"]
          expect(prepayment["amount"]).to eq -2176.95
          expect(prepayment["entries"][0]["label"]).to eq "Vorschreibung 2. Quartal 2015"
          expect(prepayment["entries"][0]["amount"]).to eq -1148.88
          expect(prepayment["entries"][1]["label"]).to eq "Kostenanteile"
          expect(prepayment["entries"][1]["amount"]).to eq -414.99
          expect(prepayment["entries"][2]["label"]).to eq "Berichtigung 2012"
          expect(prepayment["entries"][2]["amount"]).to eq -613.08

          # explanations
          parts = statement["explanations"]["parts"]

          balance_from_previous_quarters = parts.detect { |part| part["type"] == "balance_from_previous_quarters" }
          expect(balance_from_previous_quarters["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "letzter Vorschreibebetrag"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -9731.68

          # TODO period start and end
          late_interest = parts.detect { |part| part["type"] == "late_interest" }
          expect(late_interest["label"]).to eq "Verzugszinsen (VZ)"
          expect(late_interest["entries"][0]["amount_owed"]).to eq 2022.88
          expect(late_interest["entries"][0]["interest_rate"]).to eq 7.88
          expect(late_interest["entries"][0]["days"]).to eq 54
          expect(late_interest["entries"][0]["amount"]).to eq -23.59
          expect(late_interest["entries"][1]["amount_owed"]).to eq 3722.80
          expect(late_interest["entries"][1]["interest_rate"]).to eq 7.88
          expect(late_interest["entries"][1]["days"]).to eq 37
          expect(late_interest["entries"][1]["amount"]).to eq -29.74

          collection_expenses = parts.detect { |part| part["type"] == "collection_expenses" }
          expect(collection_expenses["label"]).to eq "Mahn-/Exekutionskosten"
          expect(collection_expenses["entries"][0]["date"]).to eq "2015-03-19"
          expect(collection_expenses["entries"][0]["label"]).to eq "Mahngebühr"
          expect(collection_expenses["entries"][0]["amount"]).to eq -1.00
          expect(collection_expenses["entries"][1]["date"]).to eq "2015-04-25"
          expect(collection_expenses["entries"][1]["label"]).to eq "Barauslagen bei Exekution"
          expect(collection_expenses["entries"][1]["amount"]).to eq -3.63
          expect(collection_expenses["entries"][2]["date"]).to eq "2015-04-25"
          expect(collection_expenses["entries"][2]["label"]).to eq "Exekutionsgebühren"
          expect(collection_expenses["entries"][2]["amount"]).to eq -20.06
          expect(collection_expenses["entries"][3]["date"]).to eq "2015-04-25"
          expect(collection_expenses["entries"][3]["label"]).to eq "Pauschalgebühren für Exekutionsantrag"
          expect(collection_expenses["entries"][3]["amount"]).to eq -74.50

          # TODO period start and end
          prepayment = parts.detect { |part| part["type"] == "prepayment" }
          accident_insurance = prepayment["entries"][0]
          expect(accident_insurance["label"]).to eq "UV-Beitrag ASVG"
          expect(accident_insurance["monthly_amount"]).to eq 8.90
          expect(accident_insurance["months"]).to eq 3
          expect(accident_insurance["amount"]).to eq -26.70

          retirement_pension_insurance = prepayment["entries"][1]
          expect(retirement_pension_insurance["label"]).to eq "PV-Beitrag GSVG"
          expect(retirement_pension_insurance["assessment_basis"]).to eq 1351.37
          expect(retirement_pension_insurance["rate"]).to eq 18.50
          expect(retirement_pension_insurance["monthly_amount"]).to eq 250.00
          expect(retirement_pension_insurance["months"]).to eq 3
          expect(retirement_pension_insurance["amount"]).to eq -750.00

          health_insurance = prepayment["entries"][2]
          expect(health_insurance["label"]).to eq "KV-Beitrag"
          expect(health_insurance["assessment_basis"]).to eq 1351.37
          expect(health_insurance["rate"]).to eq 7.65
          expect(health_insurance["monthly_amount"]).to eq 103.38
          expect(health_insurance["months"]).to eq 3
          expect(health_insurance["amount"]).to eq -310.14

          required_sevo = prepayment["entries"][3]
          expect(required_sevo["label"]).to eq "SeVo-Beitrag PFLICHT"
          expect(required_sevo["assessment_basis"]).to eq 1351.37
          expect(required_sevo["rate"]).to eq 1.53
          expect(required_sevo["monthly_amount"]).to eq 20.68
          expect(required_sevo["months"]).to eq 3
          expect(required_sevo["amount"]).to eq -62.04
        end
      end

      describe "PDF 4" do
        let(:number) { 4 }

        it "evaluates the given PDF file" do
          # general data
          expect(statement["name"]).to eq "Bartholomäus Speed"
          expect(statement["social_security_number"]).to eq "0004 050505"
          expect(statement["year"]).to eq 2015
          expect(statement["quarter"]).to eq 2
          expect(statement["deferred_payment_negotiated"]).to eq false

          # account balance overview
          balance_from_previous_quarters = statement["account_balance_overview"]["balance_from_previous_quarters"]
          expect(balance_from_previous_quarters["amount"]).to eq -3.12
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -4834.83
          expect(balance_from_previous_quarters["entries"][1]["label"]).to eq "Zahlungen"
          expect(balance_from_previous_quarters["entries"][1]["amount"]).to eq 3921.59
          expect(balance_from_previous_quarters["entries"][2]["label"]).to eq "Berichtigung 2015"
          expect(balance_from_previous_quarters["entries"][2]["amount"]).to eq 933.27
          expect(balance_from_previous_quarters["entries"][3]["label"]).to eq "Verzugszinsen"
          expect(balance_from_previous_quarters["entries"][3]["amount"]).to eq -22.15
          expect(balance_from_previous_quarters["entries"][4]["label"]).to eq "Mahnkosten"
          expect(balance_from_previous_quarters["entries"][4]["amount"]).to eq -1.00
          prepayment = statement["account_balance_overview"]["prepayment"]
          expect(prepayment["amount"]).to eq -2486.13
          expect(prepayment["entries"][0]["label"]).to eq "Vorschreibung 2. Quartal 2015"
          expect(prepayment["entries"][0]["amount"]).to eq -1410.69
          expect(prepayment["entries"][1]["label"]).to eq "Berichtigung 2012"
          expect(prepayment["entries"][1]["amount"]).to eq -1075.44

          # explanations
          parts = statement["explanations"]["parts"]

          balance_from_previous_quarters = parts.detect { |part| part["type"] == "balance_from_previous_quarters" }
          expect(balance_from_previous_quarters["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "letzter Vorschreibebetrag"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -4834.83

          payments = parts.detect { |part| part["type"] == "payments" }
          expect(payments["label"]).to eq "Zahlungen"
          expect(payments["entries"][0]["date"]).to eq "2015-02-10"
          expect(payments["entries"][0]["label"]).to eq "Zahlung"
          expect(payments["entries"][0]["amount"]).to eq 1415.43
          expect(payments["entries"][1]["date"]).to eq "2015-04-22"
          expect(payments["entries"][1]["label"]).to eq "Zahlung"
          expect(payments["entries"][1]["amount"]).to eq 2506.16

          # TODO period start and end
          late_interest = parts.detect { |part| part["type"] == "late_interest" }
          expect(late_interest["label"]).to eq "Verzugszinsen (VZ)"
          expect(late_interest["entries"][0]["amount_owed"]).to eq 1217.23
          expect(late_interest["entries"][0]["interest_rate"]).to eq 7.88
          expect(late_interest["entries"][0]["days"]).to eq 17
          expect(late_interest["entries"][0]["amount"]).to eq -4.47
          expect(late_interest["entries"][1]["amount_owed"]).to eq 3291.30
          expect(late_interest["entries"][1]["interest_rate"]).to eq 7.88
          expect(late_interest["entries"][1]["days"]).to eq 13
          expect(late_interest["entries"][1]["amount"]).to eq -9.24
          expect(late_interest["entries"][2]["label"]).to eq "VZ-Korrektur"
          expect(late_interest["entries"][2]["amount"]).to eq 2.48
          expect(late_interest["entries"][3]["amount_owed"]).to eq 2409.63
          expect(late_interest["entries"][3]["interest_rate"]).to eq 7.88
          expect(late_interest["entries"][3]["days"]).to eq 21
          expect(late_interest["entries"][3]["amount"]).to eq -10.92

          collection_expenses = parts.detect { |part| part["type"] == "collection_expenses" }
          expect(collection_expenses["label"]).to eq "Mahnkosten"
          expect(collection_expenses["entries"][0]["date"]).to eq "2015-03-19"
          expect(collection_expenses["entries"][0]["label"]).to eq "Mahngebühr"
          expect(collection_expenses["entries"][0]["amount"]).to eq -1.00

          # TODO period start and end
          prepayment = parts.detect { |part| part["type"] == "prepayment" }
          accident_insurance = prepayment["entries"][0]
          expect(accident_insurance["label"]).to eq "UV-Beitrag ASVG"
          expect(accident_insurance["monthly_amount"]).to eq 8.90
          expect(accident_insurance["months"]).to eq 3
          expect(accident_insurance["amount"]).to eq -26.70

          retirement_pension_insurance = prepayment["entries"][1]
          expect(retirement_pension_insurance["label"]).to eq "PV-Beitrag GSVG"
          expect(retirement_pension_insurance["assessment_basis"]).to eq 1666.67
          expect(retirement_pension_insurance["rate"]).to eq 18.50
          expect(retirement_pension_insurance["monthly_amount"]).to eq 308.33
          expect(retirement_pension_insurance["months"]).to eq 3
          expect(retirement_pension_insurance["amount"]).to eq -924.99

          health_insurance = prepayment["entries"][2]
          expect(health_insurance["label"]).to eq "KV-Beitrag"
          expect(health_insurance["assessment_basis"]).to eq 1666.67
          expect(health_insurance["rate"]).to eq 7.65
          expect(health_insurance["monthly_amount"]).to eq 127.50
          expect(health_insurance["months"]).to eq 3
          expect(health_insurance["amount"]).to eq -382.50

          required_sevo = prepayment["entries"][3]
          expect(required_sevo["label"]).to eq "SeVo-Beitrag PFLICHT"
          expect(required_sevo["assessment_basis"]).to eq 1666.67
          expect(required_sevo["rate"]).to eq 1.53
          expect(required_sevo["monthly_amount"]).to eq 25.50
          expect(required_sevo["months"]).to eq 3
          expect(required_sevo["amount"]).to eq -76.50
        end
      end

      describe "PDF 5" do
        let(:number) { 5 }

        it "evaluates the given PDF file" do
          # general data
          expect(statement["name"]).to eq "Esther Duck"
          expect(statement["social_security_number"]).to eq "0005 060606"
          expect(statement["year"]).to eq 2015
          expect(statement["quarter"]).to eq 2
          expect(statement["deferred_payment_negotiated"]).to eq false

          # account balance overview
          balance_from_previous_quarters = statement["account_balance_overview"]["balance_from_previous_quarters"]
          expect(balance_from_previous_quarters["amount"]).to eq 0.00
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -561.33
          expect(balance_from_previous_quarters["entries"][1]["label"]).to eq "Zahlungen"
          expect(balance_from_previous_quarters["entries"][1]["amount"]).to eq 561.33
          prepayment = statement["account_balance_overview"]["prepayment"]
          expect(prepayment["amount"]).to eq -561.33
          expect(prepayment["entries"][0]["label"]).to eq "Vorschreibung 2. Quartal 2015"
          expect(prepayment["entries"][0]["amount"]).to eq -561.33

          # explanations
          parts = statement["explanations"]["parts"]

          balance_from_previous_quarters = parts.detect { |part| part["type"] == "balance_from_previous_quarters" }
          expect(balance_from_previous_quarters["label"]).to eq "Saldovortrag vom 24.01.2015"
          expect(balance_from_previous_quarters["entries"][0]["label"]).to eq "letzter Vorschreibebetrag"
          expect(balance_from_previous_quarters["entries"][0]["amount"]).to eq -561.33

          payments = parts.detect { |part| part["type"] == "payments" }
          expect(payments["label"]).to eq "Zahlungen"
          expect(payments["entries"][0]["date"]).to eq "2015-02-11"
          expect(payments["entries"][0]["label"]).to eq "Zahlung"
          expect(payments["entries"][0]["amount"]).to eq 561.33

          # TODO period start and end
          prepayment = parts.detect { |part| part["type"] == "prepayment" }
          accident_insurance = prepayment["entries"][0]
          expect(accident_insurance["label"]).to eq "UV-Beitrag ASVG"
          expect(accident_insurance["monthly_amount"]).to eq 8.90
          expect(accident_insurance["months"]).to eq 3
          expect(accident_insurance["amount"]).to eq -26.70

          retirement_pension_insurance = prepayment["entries"][1]
          expect(retirement_pension_insurance["label"]).to eq "PV-Beitrag GSVG"
          expect(retirement_pension_insurance["assessment_basis"]).to eq 537.78
          expect(retirement_pension_insurance["rate"]).to eq 18.50
          expect(retirement_pension_insurance["monthly_amount"]).to eq 99.49
          expect(retirement_pension_insurance["months"]).to eq 3
          expect(retirement_pension_insurance["amount"]).to eq -298.47

          health_insurance = prepayment["entries"][2]
          expect(health_insurance["label"]).to eq "KV-Beitrag"
          expect(health_insurance["assessment_basis"]).to eq 537.78
          expect(health_insurance["rate"]).to eq 7.65
          expect(health_insurance["monthly_amount"]).to eq 41.14
          expect(health_insurance["months"]).to eq 3
          expect(health_insurance["amount"]).to eq -123.42

          additional_health_insurance = prepayment["entries"][3]
          expect(additional_health_insurance["label"]).to eq "KV-Zusatzversicherungsbeitrag"
          expect(additional_health_insurance["assessment_basis"]).to eq 1173.93
          expect(additional_health_insurance["rate"]).to eq 2.50
          expect(additional_health_insurance["monthly_amount"]).to eq 29.35
          expect(additional_health_insurance["months"]).to eq 3
          expect(additional_health_insurance["amount"]).to eq -88.05

          required_sevo = prepayment["entries"][4]
          expect(required_sevo["label"]).to eq "SeVo-Beitrag PFLICHT"
          expect(required_sevo["assessment_basis"]).to eq 537.78
          expect(required_sevo["rate"]).to eq 1.53
          expect(required_sevo["monthly_amount"]).to eq 8.23
          expect(required_sevo["months"]).to eq 3
          expect(required_sevo["amount"]).to eq -24.69
        end
      end
    end

    context "failures" do
      it "fails when a response other than JSON is requested" do
        params = { file: file_from(fixture("1.pdf"), "application/pdf") }
        headers.merge!("HTTP_ACCEPT" => "text/html")

        expect { post "/statements/parse", params, headers }.to raise_error(ActionController::UnknownFormat)

        # expect(response).to_not be_success
        # expect(response.status).to eq 406
      end

      it "fails when no file is given" do
        post "/statements/parse", { file: nil }, headers

        expect(response).to_not be_success
        expect(response.status).to eq 400
      end

      it "fails when no PDF is given" do
        post "/statements/parse", { file: file_from(fixture("1.yml"), "text/yaml") }, headers

        expect(response).to_not be_success
        expect(response.status).to eq 400
      end
    end
  end

  def file_from(file, mime_type)
    Rack::Test::UploadedFile.new(file.to_s, mime_type)
  end
end
