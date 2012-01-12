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
  
  belongs_to :analysis_task
  attr_accessible :filename
  
  before_destroy :delete_file
  
  # Get the path to a download file that is known not to exist
  #
  # This function will fetch a path for the file +basename+ in the downloads
  # folder (do not put a path of any sort on +basename+).  A unique 
  # timestamp will be appended to the filename.
  #
  # @api public
  # @param basename [String] the base name of the file to create
  # @return [String] the name of the file
  #
  # @example Get a download file name, then make a zip
  #   filename = Download.file_name('test.zip')
  #   Zip::ZipOutputStream.open(filename) do |zos| ... end
  def self.file_name(basename)
    dir = Rails.root.join('downloads')
    
    ext = File.extname(basename)
    base = File.basename(basename, ext)
    
    # Add a timestamp to the basename
    timestamp = Time.now.utc.strftime('-%Y%m%d%H%M%S')
    filename = File.join(dir, base + timestamp + ext)
    
    i = 0
    while File.exists? filename
      i = i + 1
      filename = File.join(dir, base + timestamp + i.to_s + ext)
      
      # Runaway loop counter (DoS?)
      if i == 100
        raise StandardError, "Cannot find a filename for download"
      end
    end
    
    filename
  end
  
  # Creates a download object and file, then passes the file to the block
  #
  # This function will create the file +basename+ in the downloads folder
  # (do not put a path of any sort on +basename+).  A unique timestamp will 
  # be appended to the filename, and the file created.  The file handle will
  # then be passed to the provided block.  Finally, the function creates a
  # +Download+ model, saves it in the database, and returns it.
  #
  # Closing the file within the block is optional, but recommended.
  #
  # @api public
  # @param basename [String] the base name of the file to create
  # @yield [f] Yields a File object, opened for writing
  # @yieldparam [File] f the file object created
  # @return [Download] a new +Download+ object
  #
  # @example Create a file
  #   dl = Download.create_file('test.txt') do |f|
  #     f.write("1234567890")
  #     f.close
  #   end
  def self.create_file(basename)
    filename = Download.file_name basename
        
    # Yield out to the block
    f = File.new(filename, "w")
    yield f
    
    f.close unless f.closed?
    
    # Build a Download object and return it
    Download.create({ :filename => filename })
  end
  
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
    content_type ||= 'text/plain'
    
    controller.send_file(filename,
      :x_sendfile => true,
      :type => content_type)
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
