require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FinanceRails5
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.autoload_paths << "#{Rails.root}/lib"
    config.assets.precompile += %w( .svg .eot .woff .ttf)
    config.logger = Logger.new(STDOUT)
    config.log_level = :warn
    config.generators do |g|
      g.test_framework :rspec,
                       :fixtures => true,
                       :view_specs => true,
                       :helper_specs => true,
                       :routing_specs => true,
                       :controller_specs => true,
                       :request_specs => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end
  end
end
