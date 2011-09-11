class User < ActiveRecord::Base
  validates :name, :email, :identifier, :presence => true
  validates :email, :uniqueness => true
  validates :email, :email => true
  validates :identifier, :uniqueness => true
  validates_format_of :identifier, :with => /^(#{URI::regexp(%w(http https))})$/

  def self.find_or_initialize_with_rpx(data)
    identifier = data['identifier']
    
    # Make sure that we don't return the first user (reserve for admin)
    unless identifier.nil? || identifier.blank?
      u = self.find_by_identifier(identifier)
      
      if u.nil?
        u = self.new
        u.read_rpx_response(data)
      end
    end

    u
  end

  def read_rpx_response(user_data)
    self.identifier = user_data['identifier']
    self.email = user_data['verifiedEmail'] || user_data['email']
    self.name = user_data['displayName']
  end
end
