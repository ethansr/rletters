class InfoController < ApplicationController
  skip_before_filter :login_required

  def index; end
  def privacy; end
end

