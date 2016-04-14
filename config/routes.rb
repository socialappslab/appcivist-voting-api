Rails.application.routes.draw do
  apipie
  namespace :api, :defaults => {:format => "json"} do
    namespace :v0 do
      resources :ballot, :only => [:create], :param => :uuid do
        get  "registration", :to => "ballot#registration_form"
        post "registration"
        get "results"

        resources :vote, :only => [:create, :show, :update], :param => :signature do
          put :complete, :on => :member
          put :single, :on => :member
        end
      end
    end
  end
end
