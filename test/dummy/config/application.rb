require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "rails_hush"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # disable these so they don't accidentally eat/process exceptions that RailsHush is intended to see.
    # only for testing. in real use, leave these in place.
    # config.middleware.delete ActionDispatch::DebugExceptions
    # config.middleware.delete ActionDispatch::ShowExceptions
  end
end

