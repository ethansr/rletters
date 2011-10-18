class Library < ActiveRecord::Base
  belongs_to :user
  
  validates :name, :presence => true
  validates :url, :presence => true
  validates :url, :format => { :with => /^(#{URI::regexp(%w(http https))})$/ }
  validates :user_id, :presence => true
end
