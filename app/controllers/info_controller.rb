# -*- encoding : utf-8 -*-

# Display static information pages about RLetters
#
# This controller displays static information, such as the RLetters help, FAQ,
# and privacy policy.
class InfoController < ApplicationController
  # Display a menu of all available static information about RLetters
  # @api public
  # @return [undefined]
  def index; end
  
  # Display the privacy policy
  # @api public
  # @return [undefined]
  def privacy; end
end

