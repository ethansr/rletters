# coding: UTF-8

class HelpController < ApplicationController
  def message
    render :template => 'help/message', :locals => { :dialog => true }
  end
end
