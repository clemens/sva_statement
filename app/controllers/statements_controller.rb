class StatementsController < ApplicationController
  def parse
    if params[:file].try(:content_type) == "application/pdf"
      statement = Statement.from_file(params[:file].path)

      respond_to do |format|
        format.json { render json: statement }
      end
    else
      head(:bad_request)
    end
  end
end
