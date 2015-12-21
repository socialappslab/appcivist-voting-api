Apipie.configure do |config|
  config.app_name                = "AppcivistVotingApi"
  config.app_info["v0"]          = "AppCivist Voting API Reference (version 0)"
  config.api_base_url["v0"]       = "/api/v0"
  config.doc_base_url            = "/docs/api"

  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.api_routes              = Rails.application.routes

  config.default_version = "v0"
end


# Apipie.configure do |config|
#   config.app_name                = "AppcivistVotingApi"
#   config.api_base_url            = "/api/v0"
#   config.doc_base_url            = "/documentation"
#   # config.default_version         = "0"
#
#   config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
#   config.api_routes              = Rails.application.routes
#   config.validate                = false
#   # config.default_version = 'public'
# end
