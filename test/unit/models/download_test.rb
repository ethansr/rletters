# -*- encoding : utf-8 -*-
require 'test_helper'

class DownloadTest < ActiveSupport::TestCase
  test "download with no filename should be invalid" do
    dl = Download.new
    assert !dl.valid?
  end
  
  test "minimal download should be valid" do
    dl = Download.new({ :filename => 'wut' })
    assert dl.valid?
  end
end
