# -*- encoding : utf-8 -*-

# A generated file, stored for the user to download
#
# A download object is generated when a delayed job needs to send some data
# back to the user.  We keep track of them in the database so that they can
# be expired and deleted when necessary.
#
# All files are stored in +RAILS_ROOT/downloads+, *not* in the +public+ tree.
# This folder is expected to be symlinked over from +shared+ during a
# Capistrano deployment.
#
# @attr [String] filename The filename of this download
class Download < ActiveRecord::Base
  validates :filename, :presence => true
  
  before_destroy :delete_file
  
  attr_accessible :filename
  
  # Send this download to the user
  #
  # This function does its best to guess the MIME type by looking at the file
  # extension.
  #
  # @api public
  # @param [ActionController] controller The controller to use
  # @example Send this file to the user from controller method
  #   f = @user.downloads.find_by_id('1')
  #   f.send_file(self)
  def send_file(controller)
    ext = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(ext)
    content_type = mime_type.to_s unless mime_type.nil?
    
    controller.send_file filename, :x_sendfile => true, :type => content_type
  end
  
  private
  
  # Delete the file when the database record is destroyed
  #
  # @api public
  # @return [undefined]
  def delete_file
    File::delete(filename)
  end
end
