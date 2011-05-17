# coding: UTF-8


# Support module providing an interface between our +Document+ objects and
# the {RDF.rb}[http://rdf.rubyforge.org/] library.
module RDFSupport
  
  # Convert the supplied document to an
  # {<tt>RDF::Graph</tt>}[http://rdf.rubyforge.org/RDF/Graph.html]
  # object.
  #
  # For the moment, we only provide RDF for baseline Dubline Core metadata
  # items, as well as the Dublin Core
  # {"bibliographicCitation" element.}[http://dublincore.org/documents/dc-citation-guidelines/]
  # We also encode an OpenURL reference (using the standard OpenURL namespace)
  # into a second bibliographicCitation element.  The precise way to encode
  # journal articles as DC is highly non-standard, but this should provide a
  # reasonable solution.
  def RDFSupport.document_to_rdf(document)
    graph = RDF::Graph.new
    doc = RDF::Node.new
    
    document.formatted_author_list.each do |a|
      name = ''
      name << "#{a[:von]} " unless a[:von].blank?
      name << "#{a[:last]}"
      name << " #{a[:suffix]}" unless a[:suffix].blank?
      name << ", #{a[:first]}"
      graph << [doc, RDF::DC.creator, name]
    end
    graph << [doc, RDF::DC.issued, document.year]

    citation = "#{document.journal}"
    citation << " #{document.volume}" unless document.volume.blank?
    citation << ' ' if document.volume.blank?
    citation << "(#{document.number})" unless document.number.blank?
    citation << ", #{document.pages}" unless document.pages.blank?
    citation << ". (#{document.year})"
    graph << [doc, RDF::DC.bibliographicCitation, citation]
    
    ourl = RDF::Literal.new(document.openurl_query, :datatype => RDF::URI.new("info:ofi/fmt:kev:mtx:ctx"))
    graph << [doc, RDF::DC.bibliographicCitation, ourl]
    
    graph << [doc, RDF::DC.relation, document.journal]
    graph << [doc, RDF::DC.title, document.title]
    graph << [doc, RDF::DC.type, 'Journal Article']
    graph << [doc, RDF::DC.identifier, "info:doi/#{document.doi}"] unless document.doi.blank?
    
    graph
  end
end