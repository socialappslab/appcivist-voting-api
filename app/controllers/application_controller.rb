class ApplicationController < ActionController::API
  def_param_group :ballot do
    param :ballot_uuid, String, :desc => "UUID of the ballot", :required => true
  end
end
