Rails.application.routes.draw do
  apipie
  namespace :api, :defaults => {:format => "json"} do
    namespace :v0 do
      resources :ballot, :only => [:create], :param => :uuid do
        get  "registration", :to => "ballot#registration_form"
        post "registration"

        resources :vote, :only => [:create, :show, :update], :param => :signature
      end
    end
  end
end
