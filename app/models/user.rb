class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :rpx_connectable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  # Get the info from Janrain and put it in the model
  def on_before_rpx_success(rpx_data)
    n = rpx_data["name"]
    self.name = n["formatted"] unless n.nil?
    self.email = rpx_data["verifiedEmail"]
    self.email ||= rpx_data["email"]
  end
end
