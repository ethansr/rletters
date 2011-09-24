# -*- encoding : utf-8 -*-
# -*- coding: undecided -*-
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

  test "find_all_by_solr_query should throw on Solr error" do
    stub_solr_response(SOLR_RESPONSE_ERROR)
    assert_raise(ActiveRecord::StatementInvalid) { Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" }) }
  end

  test "find_all_by_solr_query should return empty array for no docs" do
    stub_solr_response(SOLR_RESPONSE_EMPTY)
    assert_equal(Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" }), [])
  end

  test "find_all_by_solr_query should work for good response" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })
    assert_equal(docs.count, 5)
  end

  test "find_all_by_solr_query should load all document attributes" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })

    # Check one of each attribute
    assert_equal(docs[0].shasum, '8e740d30df3f9941e2ca059ef6896830c8a8e226')
    assert_equal(docs[3].doi, '10.1111/j.1601-183X.2009.00489.x')
    assert_equal(docs[1].authors, 'T. M. Freeberg')
    assert_equal(docs[2].title, 'David C. Geary: The origin of mind: evolution of brain, cognition and general intelligence')
    assert_equal(docs[0].journal, 'Genes, Brain and Behavior')
    assert_equal(docs[2].year, '2006')
    assert_equal(docs[3].volume, '8')
    assert_nil(docs[4].number)
    assert_equal(docs[4].pages, '17-27')
    assert(docs[1].fulltext.start_with?('Oyama, S. 2000: The Ontogeny of Information:'))
  end

  test "find_all_by_solr_query should set facets" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })

    # Check some of each of the facets
    assert_not_nil(Document.facets)
    assert_not_nil(Document.facets[:author])
    assert_equal(Document.facets[:author]['Augusto Vitale'], 2)
    assert_equal(Document.facets[:author]['Bert Hölldobler'], 1)
    assert_nil(Document.facets[:author]['W. Shatner'])

    assert_not_nil(Document.facets[:journal])
    assert_equal(Document.facets[:journal]['Genes, Brain and Behavior'], 5)
    assert_nil(Document.facets[:journal]['Journal of Nothing'])

    assert_not_nil(Document.facets[:year])
    assert_equal(Document.facets[:year]['1940'], 0)
    assert_equal(Document.facets[:year]['2000'], 25)
  end
end
