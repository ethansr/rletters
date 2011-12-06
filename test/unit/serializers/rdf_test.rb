# -*- encoding : utf-8 -*-
require 'minitest_helper'

class RDFTest < ActiveSupport::TestCase
  test "should create good RDF graphs" do
    SolrExamples.stub(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    graph = doc.to_rdf
    rdf_docs = RDF::Query.execute(graph, {
      :doc => {
        RDF::DC.type => 'Journal Article',
        RDF::DC.issued => :year,
        RDF::DC.relation => :journal,
        RDF::DC.title => :title,
        RDF::DC.identifier => :doistr
      }
    })
    assert_equal 1, rdf_docs.count
    
    assert_equal 'Ethology', rdf_docs[0].journal.to_s
    assert_equal '2008', rdf_docs[0].year.to_s
    assert_equal 'How Reliable are the Methods for Estimating Repertoire Size?', rdf_docs[0].title.to_s
    assert_equal 'info:doi/10.1111/j.1439-0310.2008.01576.x', rdf_docs[0].doistr.to_s
    
    rdf_docs = RDF::Query.execute(graph, {
      :doc => {
        RDF::DC.type => 'Journal Article',
        RDF::DC.creator => :author
      }
    })
    
    assert_equal 5, rdf_docs.count
    good = [ 'Botero, Carlos A.', 'Mudge, Andrew E.', 'Koltz, Amanda M.',
      'Hochachka, Wesley M.', 'Vehrencamp, Sandra L.' ]
    rdf_docs.each do |d|
      assert good.include? d.author.to_s
    end
    
    rdf_docs = RDF::Query.execute(graph, {
      :doc => {
        RDF::DC.type => 'Journal Article',
        RDF::DC.bibliographicCitation => :citation
      }
    })
    
    assert_equal 2, rdf_docs.count
    good = [ "&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A" \
      "mtx%3Ajournal&rft.genre=article&" \
      "rft_id=info:doi%2F10.1111%2Fj.1439-0310.2008.01576.x" \
      "&rft.atitle=How+Reliable+are+the+Methods+for+" \
      "Estimating+Repertoire+Size%3F" \
      "&rft.title=Ethology&rft.date=2008&rft.volume=114" \
      "&rft.spage=1227&rft.epage=1238&rft.aufirst=Carlos+A." \
      "&rft.aulast=Botero&rft.au=Andrew+E.+Mudge" \
      "&rft.au=Amanda+M.+Koltz&rft.au=Wesley+M.+Hochachka" \
      "&rft.au=Sandra+L.+Vehrencamp", 
      "Ethology 114, 1227-1238. (2008)" ]
    rdf_docs.each do |d|
      assert good.include? d.citation.to_s
    end
  end
end
