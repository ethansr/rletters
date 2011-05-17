# coding: UTF-8

require 'tempfile'
require 'zip/zip'
require 'zip/zipfilesystem'

# Class which encapsulates the export of a collection of +Document+ instances
# to MARC format.
#
# Unlike many of our other export formats, MARC doesn't support the creation 
# of one file containing multiple records, so we have to send the user a ZIP 
# file if they ask for more than one document.  This means that, unlike the
# rest of the +*Collection+ classes, this class has no +to_s+ method, as
# it would not be able to return if there was more than one document in the
# collection.
class MARCCollection
  
  # Create a new MARC collection.  +documents+ should be an array of 
  # +Document+ objects.
  def initialize(documents)
    @documents = documents
  end
  
  # Convert to MARC and send to the client using the 
  # <tt>controller.send_data</tt> method of an <tt>ActionController.</tt>
  #
  # As mentioned above, this method will either send an individual MARC record
  # (if <tt>@documents.length = 1</tt>), or a ZIP file containing multiple
  # MARC records.
  def send(controller)
    if @documents.length == 1
      controller.send_data MARCSupport.document_to_marc(@documents[0]).to_marc,
        :filename => "export.marc", :type => 'application/marc',
        :disposition => 'attachment'
    else
      t = Tempfile.new 'marc-collection-zip', "#{Rails.root}/tmp"
      begin
        Zip::ZipOutputStream.open(t.path) do |zos|
          @documents.each_with_index do |d, i|
            zos.put_next_entry("export#{i}.marc")
            zos.print MARCSupport.document_to_marc(d).to_marc
          end
        end
        
        t.rewind
        controller.send_data t.read, :type => 'application/zip', 
          :disposition => 'attachment', :filename => 'export_marc.zip'        
      ensure
        t.close
      end      
    end
  end
end
