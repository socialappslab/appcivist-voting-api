class ApplicationController < ActionController::API
  def_param_group :ballot do
    param :ballot_uuid, String, :desc => "UUID of the ballot", :required => true
  end

  def identify_ballot
    @ballot = Ballot.find_by_uuid(params[:ballot_uuid])
    if @ballot.blank?
      render :json => {:error => "Ballot does not exist"}, :status => 404 and return
    end
  end
end
