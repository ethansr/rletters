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
end
