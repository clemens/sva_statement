class StatementsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def parse
    if params[:file].try(:content_type) == "application/pdf"
      statement = Statement.from_file(params[:file].path)

      respond_to do |format|
        format.json { render json: statement }
      end
    else
      respond_to do |format|
        format.json { head(:bad_request) }
        format.html do
          flash.now[:alert] = "Bitte laden Sie eine korrekte PDF-Datei mit einem SVA-Kontoauszug hoch!"

          render :upload, status: :bad_request
        end
      end
    end
  end
end
