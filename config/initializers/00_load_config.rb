APP_CONFIG = YAML.load_file(Rails.root.join('config', 'app_config.yml'))[Rails.env]

# Set some config values that come out of APP_CONFIG
RLetters::Application.config.action_mailer.default_url_options = { :host => APP_CONFIG['app_domain'] }

