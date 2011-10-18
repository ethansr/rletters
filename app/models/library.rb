# -*- encoding : utf-8 -*-
class Library < ActiveRecord::Base
  belongs_to :user
  
  validates :name, :presence => true
  validates :url, :presence => true
  validates :url, :format => { :with => /^(#{URI::regexp(%w(http https))})$/ }
  validates :user_id, :presence => true
  
  attr_accessible :url, :name

  protected
  
  before_validation do |library|
    unless library.url.blank?
      library.url = "http://" + url unless library.url.start_with? "http"
      library.url = library.url + "?" unless library.url.end_with? "?"
    end
  end
end
