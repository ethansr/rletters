# coding: UTF-8

require 'rdf/raptor'

class RDFCollection
  def initialize(documents)
    @documents = documents
  end
  
  def to_s
    RDF::Writer.for(:rdfxml).buffer do |writer|
      @documents.each do |d|
        writer << RDFSupport.document_to_rdf(d)
      end
    end
  end

  def send(controller)
    controller.send_data to_s, :filename => "evotext_export.rdf", 
      :type => 'application/rdf+xml', :disposition => 'attachment'
  end
end
