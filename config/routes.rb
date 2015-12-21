Rails.application.routes.draw do
  namespace :api, :defaults => {:format => "json"} do
    namespace :v0 do
      resources :ballot, :only => [:create] do
        get  "registration", :to => "ballot#registration_form"
        post "registration"

        resources :vote, :only => [:create, :show, :update]
      end
    end
  end
end
