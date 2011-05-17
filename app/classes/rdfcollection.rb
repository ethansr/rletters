# coding: UTF-8

require 'rdf/raptor'

# Class which encapsulates the export of a collection of +Document+ instances
# to RDF/XML format.
class RDFCollection
  
  # Create a new RDF/XML collection.  +documents+ should be an array of 
  # +Document+ objects.
  def initialize(documents)
    @documents = documents
  end
  
  # Convert the array of documents to a string containing the RDF/XML records
  # for the entire collection.
  def to_s
    RDF::Writer.for(:rdfxml).buffer do |writer|
      @documents.each do |d|
        writer << RDFSupport.document_to_rdf(d)
      end
    end
  end
  
  # Convert to RDF/XML and send to the client using the 
  # <tt>controller.send_data</tt> method of an <tt>ActionController.</tt>
  def send(controller)
    controller.send_data to_s, :filename => "export.rdf", 
      :type => 'application/rdf+xml', :disposition => 'attachment'
  end
end
