# coding: UTF-8


# Class which encapsulates the export of a collection of +Document+ instances
# to MARCXML format.
class MARCXMLCollection
  
  # Create a new MARCXML collection.  +documents+ should be an array of 
  # +Document+ objects.
  def initialize(documents)
    @documents = documents
  end
  
  # Convert the array of documents to a string containing the MARCXML records
  # for the entire collection.
  def to_s
    marc_records = @documents.map { |d| MARCSupport.document_to_marc(d) }
    xml_documents = marc_records.map { |r| MARC::XMLWriter.encode(r) }
    
    document = REXML::Document.new
    
    collection = REXML::Element.new 'collection'
    collection.add_attribute('xmlns', 'http://www.loc.gov/MARC21/slim')
    
    xml_documents.each { |d| collection.add(d.root) }
    
    document << REXML::XMLDecl.new
    document << collection
    
    ret = ''
    document.write(ret, 2)
    ret
  end
  
  # Convert to MARCXML and send to the client using the 
  # <tt>controller.send_data</tt> method of an <tt>ActionController.</tt>
  def send(controller)
    controller.send_data to_s, :filename => "export_marcxml.xml", 
      :type => 'application/marcxml+xml', :disposition => 'attachment'
  end
end
