# -*- encoding : utf-8 -*-

# Enable UTF-8 everywhere on Ruby 1.8
$KCODE = "U" if RUBY_VERSION < "1.9.0"

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
RLetters::Application.initialize!
