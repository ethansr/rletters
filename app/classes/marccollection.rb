require 'tempfile'
require 'zip/zip'
require 'zip/zipfilesystem'

# MARC doesn't support multiple files for an individual record, so we have
# to send the user a ZIP if they ask for more than one document.
class MARCCollection
  def initialize(documents)
    @documents = documents
  end

  def send(controller)
    if @documents.length == 1
      controller.send_data MARCSupport.document_to_marc(@documents[0]).to_marc,
        :filename => "evotext_export.marc", :type => 'application/marc',
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
          :disposition => 'attachment', :filename => 'evotext_export_marc.zip'        
      ensure
        t.close
      end      
    end
  end
end
