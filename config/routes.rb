Rails.application.routes.draw do
  namespace :api, :defaults => {:format => "json"} do
    namespace :v0 do
      resources :ballot, :only => [] do
        get  "registration"
        post "registration"

        resources :vote, :only => [:create, :show, :update]
      end
    end
  end
end
