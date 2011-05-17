# coding: UTF-8

require 'rdf/raptor'

# Class which encapsulates the export of a collection of +Document+ instances
# to RDF/Turtle format.
class TurtleCollection
  
  # Create a new RDF/Turtle collection.  +documents+ should be an array of 
  # +Document+ objects.
  def initialize(documents)
    @documents = documents
  end
  
  # Convert the array of documents to a string containing the RDF/Turtle
  # records for the entire collection.
  def to_s
    RDF::Writer.for(:turtle).buffer do |writer|
      @documents.each do |d|
        writer << RDFSupport.document_to_rdf(d)
      end
    end
  end
  
  # Convert to RDF/Turtle and send to the client using the 
  # <tt>controller.send_data</tt> method of an <tt>ActionController.</tt>
  def send(controller)
    controller.send_data to_s, :filename => "export.ttl", 
      :type => 'text/turtle', :disposition => 'attachment'
  end
end
