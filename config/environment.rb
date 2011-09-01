# coding: UTF-8

# Load the rails application
require File.expand_path('../application', __FILE__)

# Set some Haml options
Haml::Template.options[:format] = :html5
Haml::Template.options[:encoding] = 'utf-8'

# Initialize the rails application
RLetters::Application.initialize!
