# -*- encoding : utf-8 -*-
require 'test_helper'

class LibraryTest < ActiveSupport::TestCase

  test "should not save empty library" do
    library = Library.new
    assert !library.save, 'Saved an empty library'
  end
  
  test "should not save without name" do
    library = Library.new
    library.url = "http://google.com/"    
    library.user = users(:john)
    assert !library.save, 'Saved a library without URL'
  end
  
  test "should not save without user" do
    library = Library.new
    library.name = "Google"
    library.url = "http://google.com/"
    assert !library.save, 'Saved a library without user'
  end
  
  test "should not save without URL" do
    library = Library.new
    library.name = "Google"
    library.user = users(:john)
    assert !library.save, 'Saved a library without URL'
  end
  
  test "should save minimal library" do
    library = Library.new
    library.name = "Google"
    library.user = users(:john)
    library.url = "http://google.com/"
    assert library.save, 'Failed to save valid library'
  end
  
  test "should save library with no-HTTP url" do
    library = Library.new    
    library.name = "Google"
    library.user = users(:john)
    library.url = "google.com"
    assert library.save
  end

  test "should give library URL a question mark on save" do
    library = Library.new    
    library.name = "Google"
    library.user = users(:john)
    library.url = "http://google.com"
    assert library.save
    assert_equal "http://google.com?", library.url
  end
end