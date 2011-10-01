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
    doc = Document.new({ "shasum" => "1234567890abcdef0987" })
    assert doc.valid?
  end

  test "should parse authors into author_list correctly" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    doc = Document.find_with_fulltext('8e740d30df3f9941e2ca059ef6896830c8a8e226')
    assert_equal 3, doc.author_list.count
    assert_equal "Nadia Francia", doc.author_list[0]
    assert_equal "Augusto Vitale", doc.author_list[1]
    assert_equal "Enrico Alleva", doc.author_list[2]
  end

  test "should parse authors into formatted_author_list correctly" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    doc = Document.find_with_fulltext('8e740d30df3f9941e2ca059ef6896830c8a8e226')
    assert_equal 3, doc.formatted_author_list.count
    assert_equal "Nadia", doc.formatted_author_list[0][:first]
    assert_equal "Alleva", doc.formatted_author_list[2][:last]
  end

  test "find should throw on Solr error" do
    stub_solr_response(SOLR_RESPONSE_ERROR)
    assert_raise(ActiveRecord::StatementInvalid) { Document.find('wut') }
  end

  test "find should throw on no documents" do
    stub_solr_response(SOLR_RESPONSE_EMPTY)
    assert_raise(ActiveRecord::RecordNotFound) { Document.find('wut') }
  end

  test "find should succeed for valid doc" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    doc = Document.find('8e740d30df3f9941e2ca059ef6896830c8a8e226')
    assert_not_nil(doc)
    assert_equal('8e740d30df3f9941e2ca059ef6896830c8a8e226', doc.shasum)
  end

  test "find_with_fulltext should throw on Solr error" do
    stub_solr_response(SOLR_RESPONSE_ERROR)
    assert_raise(ActiveRecord::StatementInvalid) { Document.find_with_fulltext('wut') }
  end

  test "find_with_fulltext should throw on no documents" do
    stub_solr_response(SOLR_RESPONSE_EMPTY)
    assert_raise(ActiveRecord::RecordNotFound) { Document.find_with_fulltext('wut') }
  end

  test "find_with_fulltext should succeed for valid doc" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    doc = Document.find_with_fulltext('8e740d30df3f9941e2ca059ef6896830c8a8e226')
    assert_not_nil(doc)
    assert_equal('8e740d30df3f9941e2ca059ef6896830c8a8e226', doc.shasum)
  end

  test "find_all_by_solr_query should throw on Solr error" do
    stub_solr_response(SOLR_RESPONSE_ERROR)
    assert_raise(ActiveRecord::StatementInvalid) { Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" }) }
  end

  test "find_all_by_solr_query should return empty array for no docs" do
    stub_solr_response(SOLR_RESPONSE_EMPTY)
    assert_equal([], Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" }))
  end

  test "find_all_by_solr_query should work for good response" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })
    assert_equal(5, docs.count)
  end

  test "find_all_by_solr_query should set num_results" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })
    assert_equal(5, Document.num_results)
  end

  test "find_all_by_solr_query should load all document attributes" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })

    # Check one of each attribute
    assert_equal('8e740d30df3f9941e2ca059ef6896830c8a8e226', docs[0].shasum)
    assert_equal('10.1111/j.1601-183X.2009.00489.x', docs[3].doi)
    assert_equal('T. M. Freeberg', docs[1].authors)
    assert_equal('David C. Geary: The origin of mind: evolution of brain, cognition and general intelligence', docs[2].title)
    assert_equal('Genes, Brain and Behavior', docs[0].journal)
    assert_equal('2006', docs[2].year)
    assert_equal('8', docs[3].volume)
    assert_nil(docs[4].number)
    assert_equal('17-27', docs[4].pages)
    assert(docs[1].fulltext.start_with?('Oyama, S. 2000: The Ontogeny of Information:'))
  end

  test "find_all_by_solr_query should set facets" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })

    # Check some of each of the facets
    assert_not_nil(Document.facets)
    assert_not_nil(Document.facets[:authors_facet])
    assert_equal(2, Document.facets[:authors_facet]['Augusto Vitale'])
    assert_equal(1, Document.facets[:authors_facet]['Bert Hölldobler'])
    assert_nil(Document.facets[:authors_facet]['W. Shatner'])

    assert_not_nil(Document.facets[:journal_facet])
    assert_equal(5, Document.facets[:journal_facet]['Genes, Brain and Behavior'])
    assert_nil(Document.facets[:journal_facet]['Journal of Nothing'])

    assert_not_nil(Document.facets[:year])
    assert_equal(0, Document.facets[:year]['1940–1949'])
    assert_equal(25, Document.facets[:year]['2000–2009'])
  end

  test "find_all_by_solr_query should not set TV if not found" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })
    assert_nil(docs[0].term_vectors)
  end

  test "find_all_by_solr_query should parse response with term vectors" do
    stub_solr_response(SOLR_RESPONSE_TV)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "fulltext" })
    assert_equal(1, docs.count)
  end

  test "find_all_by_solr_query should not set facets if not found" do
    stub_solr_response(SOLR_RESPONSE_TV)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "fulltext" })
    assert_nil(Document.facets)
  end

  test "find_all_by_solr_query should set term vectors correctly" do
    stub_solr_response(SOLR_RESPONSE_TV)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "fulltext" })
    
    # Check a couple of these to make sure the parsing is good
    assert_not_nil(docs[0].term_vectors)
    assert_equal(9, docs[0].term_vectors["chapter"][:tf])
    assert_equal((542...545), docs[0].term_vectors["can"][:offsets][2])
    assert_equal(552, docs[0].term_vectors["can"][:positions][3])
    assert_equal(564, docs[0].term_vectors["cell"][:df])
    assert_equal(0.01, docs[0].term_vectors["capabilities"][:tfidf])
    assert_nil(docs[0].term_vectors["zuzax"])
  end
end
