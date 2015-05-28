require "rails_helper"

RSpec.describe "Statements API", type: :request do
  describe "GET to #parse" do
    let(:headers) { { "HTTP_ACCEPT" => "application/json" } }

    context "when given a PDF file" do
      it "evaluates the given PDF file" do
        data = YAML.load_file(fixture("1.yml"))
        params = { file: file_from(fixture("1.pdf"), "application/pdf") }

        post "/statements/parse", params, headers

        expect(response).to be_success

        statement = JSON.parse(response.body)

        # general data
        expect(statement["name"]).to eq "Martina Musterfrau"
        expect(statement["social_security_number"]).to eq "0001 020202"
        expect(statement["year"]).to eq 2015
        expect(statement["quarter"]).to eq 2

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
