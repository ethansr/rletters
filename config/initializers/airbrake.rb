# -*- encoding : utf-8 -*-

# Set the Airbrake key and start up Airbrake, if available
unless APP_CONFIG['airbrake_key'].blank?
  Airbrake.configure do |config|
    config.api_key = APP_CONFIG['airbrake_key']
  end
end
