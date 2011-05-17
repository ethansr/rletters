# coding: UTF-8


class MARCXMLCollection
  def initialize(documents)
    @documents = documents
  end
  
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

  def send(controller)
    controller.send_data to_s, :filename => "export_marcxml.xml", 
      :type => 'application/marcxml+xml', :disposition => 'attachment'
  end
end
