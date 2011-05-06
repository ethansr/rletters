require 'rdf/raptor'

class TurtleCollection
  def initialize(documents)
    @documents = documents
  end
  
  def to_s
    RDF::Writer.for(:turtle).buffer do |writer|
      @documents.each do |d|
        writer << RDFSupport.document_to_rdf(d)
      end
    end
  end

  def send(controller)
    controller.send_data to_s, :filename => "evotext_export.ttl", 
      :type => 'text/turtle', :disposition => 'attachment'
  end
end
