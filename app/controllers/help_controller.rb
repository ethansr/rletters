class HelpController < ApplicationController
  def message
    render :template => 'help/message.html.haml', :layout => false
  end
end
