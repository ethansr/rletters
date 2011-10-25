# -*- encoding : utf-8 -*-
require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    # Required for ActiveModel tests
    @model = Document.new
  end

  test "document with no shasum should be invalid" do
    doc = Document.new
    assert !doc.valid?
  end

  test "document with short shasum should be invalid" do
    doc = Document.new({ "shasum" => "notanshasum" })
    assert !doc.valid?
  end

  test "document with bad shasum should be invalid" do
    doc = Document.new({ "shasum" => "1234567890thisisbad!" })
    assert !doc.valid?
  end

  test "minimal document should be valid" do
    doc = Document.new({ "shasum" => "00972c5123877961056b21aea4177d0dc69c7318" })
    assert doc.valid?
  end

  test "should parse authors into author_list correctly" do
    stub_solr_response(:fulltext_one_doc)
    doc = Document.find_with_fulltext('00972c5123877961056b21aea4177d0dc69c7318')
    assert_equal 5, doc.author_list.count
    assert_equal "Carlos A. Botero", doc.author_list[0]
    assert_equal "Wesley M. Hochachka", doc.author_list[3]
  end

  test "should parse authors into formatted_author_list correctly" do
    stub_solr_response(:fulltext_one_doc)
    doc = Document.find_with_fulltext('00972c5123877961056b21aea4177d0dc69c7318')
    assert_equal 5, doc.formatted_author_list.count
    assert_equal "Andrew E.", doc.formatted_author_list[1][:first]
    assert_equal "Vehrencamp", doc.formatted_author_list[4][:last]
  end
  
  test "should parse start and end pages correctly" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    assert_equal '1227', doc.start_page
    assert_equal '1238', doc.end_page
  end
  
  test "should parse start and end pages correctly with short range" do
    doc = Document.new({ "shasum" => "00972c5123877961056b21aea4177d0dc69c7318", "pages" => "1483-92" })
    assert_equal '1483', doc.start_page
    assert_equal '1492', doc.end_page
  end

  test "find should throw on Solr error" do
    stub_solr_response(:error)
    assert_raise(ActiveRecord::StatementInvalid) { Document.find('FAILURE') }
  end

  test "find should throw on no documents" do
    stub_solr_response(:standard_empty_search)
    assert_raise(ActiveRecord::RecordNotFound) { Document.find('shatner') }
  end

  test "find should succeed for valid doc" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    assert_not_nil(doc)
    assert_equal('00972c5123877961056b21aea4177d0dc69c7318', doc.shasum)
    assert_nil(doc.fulltext)
  end

  test "find_with_fulltext should throw on Solr error" do
    stub_solr_response(:error)
    assert_raise(ActiveRecord::StatementInvalid) { Document.find_with_fulltext('FAILURE') }
  end

  test "find_with_fulltext should throw on no documents" do
    stub_solr_response(:standard_empty_search)
    assert_raise(ActiveRecord::RecordNotFound) { Document.find_with_fulltext('shatner') }
  end

  test "find_with_fulltext should succeed for valid doc" do
    stub_solr_response(:fulltext_one_doc)
    doc = Document.find_with_fulltext('00972c5123877961056b21aea4177d0dc69c7318')
    assert_not_nil(doc)
    assert_equal('00972c5123877961056b21aea4177d0dc69c7318', doc.shasum)
    assert_not_nil(doc.fulltext)
  end

  test "find_all_by_solr_query should throw on Solr error" do
    stub_solr_response(:error)
    assert_raise(ActiveRecord::StatementInvalid) { Document.find_all_by_solr_query({ :q => "FAILURE", :qt => "standard" }) }
  end

  test "find_all_by_solr_query should return empty array for no docs" do
    stub_solr_response(:standard_empty_search)
    assert_equal([], Document.find_all_by_solr_query({ :q => "shatner", :qt => "standard" }))
  end

  test "find_all_by_solr_query should work for good response" do
    stub_solr_response(:precise_all_docs)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })
    assert_equal(10, docs.count)
  end

  test "find_all_by_solr_query should set num_results" do
    stub_solr_response(:precise_all_docs)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })
    assert_equal(10, Document.num_results)
  end

  test "find_all_by_solr_query should load all document attributes" do
    stub_solr_response(:precise_all_docs)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })

    # Check one of each attribute
    assert_equal('00040b66948f49c3a6c6c0977530e2014899abf9', docs[0].shasum)
    assert_equal('10.1111/j.1439-0310.2009.01716.x', docs[3].doi)
    assert_equal('Troy G. Murphy', docs[9].authors)
    assert_equal('New Books', docs[2].title)
    assert_equal('Ethology', docs[0].journal)
    assert_equal('2001', docs[5].year)
    assert_equal('104', docs[7].volume)
    assert_nil(docs[4].number)
    assert_equal('181-187', docs[8].pages)
    # The precise search does not set fulltext
    assert_nil(docs[1].fulltext)
  end

  test "find_all_by_solr_query should set facets" do
    stub_solr_response(:precise_all_docs)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })

    # Check some of each of the facets
    assert_not_nil(Document.facets)
    assert_not_nil(Document.facets[:authors_facet])
    assert_equal(1, Document.facets[:authors_facet]['Amanda M. Koltz'])
    assert_equal(1, Document.facets[:authors_facet]['Jennifer L. Snekser'])
    assert_nil(Document.facets[:authors_facet]['W. Shatner'])

    assert_not_nil(Document.facets[:journal_facet])
    assert_equal(10, Document.facets[:journal_facet]['Ethology'])
    assert_nil(Document.facets[:journal_facet]['Journal of Nothing'])

    assert_not_nil(Document.facets[:year])
    assert_equal(0, Document.facets[:year]['1940–1949'])
    assert_equal(7, Document.facets[:year]['2000–2009'])
  end

  test "find_all_by_solr_query should not set TV if not found" do
    stub_solr_response(:precise_one_doc)
    docs = Document.find_all_by_solr_query({ :q => "shasum:00972c5123877961056b21aea4177d0dc69c7318", :qt => "precise" })
    assert_nil(docs[0].term_vectors)
  end

  test "find_all_by_solr_query should parse response with term vectors" do
    stub_solr_response(:fulltext_one_doc)
    docs = Document.find_all_by_solr_query({ :q => "shasum:00972c5123877961056b21aea4177d0dc69c7318", :qt => "fulltext" })
    assert_equal(1, docs.count)
  end

  test "find_all_by_solr_query should not set facets if not found" do
    stub_solr_response(:fulltext_one_doc)
    docs = Document.find_all_by_solr_query({ :q => "shasum:00972c5123877961056b21aea4177d0dc69c7318", :qt => "fulltext" })
    assert_nil(Document.facets)
  end

  test "find_all_by_solr_query should set term vectors correctly" do
    stub_solr_response(:fulltext_one_doc)
    docs = Document.find_all_by_solr_query({ :q => "shasum:00972c5123877961056b21aea4177d0dc69c7318", :qt => "fulltext" })
    
    # Check a couple of these to make sure the parsing is good
    assert_not_nil(docs[0].term_vectors)
    assert_equal(3, docs[0].term_vectors["cornell"][:tf])
    assert_equal((527...539), docs[0].term_vectors["neurobiology"][:offsets][0])
    assert_equal(2, docs[0].term_vectors["reliable"][:positions][0])
    assert_equal(2, docs[0].term_vectors["laboratory"][:df])
    assert_equal(1.0, docs[0].term_vectors["humboldt"][:tfidf])
    assert_nil(docs[0].term_vectors["zuzax"])
  end
end
