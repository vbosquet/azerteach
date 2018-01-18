require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Azerteach
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #
    config.time_zone = 'Brussels'
    config.action_mailer.smtp_settings = {
      :address => "in.mailjet.com",
      :enable_starttls_auto => true,
      :port => 587,
      :authentication => 'plain',
      :user_name => "7a8301da96255412bf4e76fc1bf1b5be",
      :password => "689c8321f5e70cda718db1c3cbe86b3a"
    }
  end
end
