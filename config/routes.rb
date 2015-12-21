Rails.application.routes.draw do
  namespace :api, :defaults => {:format => "json"} do
    namespace :v0 do
      resources :ballots, :only => [:show]
    end
  end
end
