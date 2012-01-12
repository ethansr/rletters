# -*- encoding : utf-8 -*-

# Representation of a user in the database
#
# RLetters keeps track of users so that it can send e-mails regarding
# background jobs and keep a set of customizable user options.
#
# @attr [String] name Full name
# @attr [String] email E-mail address
# @attr [String] identifier URL identifier of third-party profile
# @attr [Integer] per_page Number of search results to display per page
# @attr [String] language Locale code of user's preferred language
# @attr [String] timezone User's timezone, in Rails' format
# @attr [String] csl_style User's preferred citation style, blank 
#   for default
#
# @attr [Array<Dataset>] datasets All datasets created by the user (+has_many+)
# @attr [Array<Library>] libraries All library links added by the user (+has_many+)
class User < ActiveRecord::Base
  validates :name, :email, :identifier, :presence => true
  validates :email, :uniqueness => true
  validates :email, :email => true
  validates :identifier, :uniqueness => true
  validates :identifier, :format => { :with => /^(#{URI::regexp(%w(http https))})$/u }
  validates :per_page, :presence => true
  validates :per_page, :numericality => { :only_integer => true }
  validates :per_page, :inclusion => { :in => 1..9999999999 }
  validates :language, :presence => true
  validates :language, :format => { :with => /\A[a-z]{2,3}(-[A-Z]{2})?\Z/u }
  validates :timezone, :presence => true

  has_many :datasets, :dependent => :delete_all
  has_many :libraries, :dependent => :delete_all

  validates_associated :datasets
  validates_associated :libraries

  # Attributes that can be edited by the user (in the user options form) 
  # should be whitelisted here.  Programmatic-access things (like datasets or
  # the RPX identifier) do *not* need to occur here.
  attr_accessible :name, :email, :per_page, :language, :csl_style, :libraries, :timezone

  # Locate current user (or create new) from an Engage response
  #
  # This function uses the RPX response provided to determine if we already
  # have a user with a given identifier.  If so, that user is returned.
  # Otherwise, a new user is created, and the new-user form is shown.
  #
  # @api public
  # @param [Hash] data hash response returned by the Engage server
  # @return [User] user with the given identifier, possibly new
  # @example Log in a user (from an Engage callback)
  #   data = {}
  #   RPXNow.user_data(params[:token], :additional => [:name, :email, :verifiedEmail]) { |raw| data = raw['profile'] }
  #   @user = User.find_or_initialize_with_rpx(data)
  # @see UsersController#rpx
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

  # Parse the response from the Engage server
  #
  # The first time a user logs in from Janrain Engage, we need to parse the
  # returned data to extract their identifier, name, and email address.
  #
  # @api public
  # @param [Hash] user_data hash response returned by the Engage server
  # @return [undefined]
  def read_rpx_response(user_data)
    self.identifier = user_data['identifier']
    self.email = user_data['verifiedEmail'] || user_data['email']
    self.name = user_data['displayName']
  end
end
