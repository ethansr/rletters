# coding: UTF-8


# Controller for displaying help messages to the user.
class HelpController < ApplicationController
  
  # Display one help message as a jQuery Mobile dialog.
  def message
    render :template => 'help/message', :locals => { :dialog => true }
  end
end
