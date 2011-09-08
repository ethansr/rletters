APP_CONFIG = YAML.load_file(Rails.root.join('config', 'app_config.yml'))[Rails.env]

# Load some configuration bits that live in APP_CONFIG
RPXNow.api_key = APP_CONFIG['janrain_secret']

