# -*- encoding : utf-8 -*-
require 'minitest_helper'

class DownloadTest < ActiveRecord::TestCase
  test "download with no filename should be invalid" do
    dl = Download.new
    assert !dl.valid?
  end
  
  test "minimal download should be valid" do
    dl = Download.new({ :filename => 'wut' })
    assert dl.valid?
  end
  
  test "should be able to create/delete standard download file" do
    dl = Download.create_file 'test.txt' do |f|
      f.write("1234567890")
    end
    refute_nil dl
    
    fn = dl.filename
    assert File.exists?(fn)
    
    f = File.open(fn, "r")
    assert_equal "1234567890", f.read
    f.close
    
    dl.destroy
    assert !File.exists?(fn)
  end
end
