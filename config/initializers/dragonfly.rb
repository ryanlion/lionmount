require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "590a8be7ae7d15df93960a9a8ff7e5f0af3fb70f5cbc428663357d7cc440fdd5"

  url_format "/media/:job/:name"

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    server_root: Rails.root.join('public')
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
