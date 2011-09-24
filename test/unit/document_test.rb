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
end
