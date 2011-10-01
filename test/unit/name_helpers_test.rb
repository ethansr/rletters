# -*- encoding : utf-8 -*-
require 'test_helper'

class NameHelpersTest < ActiveSupport::TestCase

  #
  # Many thanks to Xavier Decoret for this test suite:
  # http://tinyurl.com/6bebaqp
  #
  def test_name_parts(n, first, von, last, suffix)
    ret = NameHelpers.name_parts(n)
    assert_equal first, ret[:first]
    assert_equal von, ret[:von]
    assert_equal last, ret[:last]
    assert_equal suffix, ret[:suffix]
  end

  test "should parse Decoret test suite, abridged" do
    test_name_parts("AA BB", "AA", "", "BB", "")
    test_name_parts("AA", "", "", "AA", "")
    test_name_parts("AA bb", "AA", "", "bb", "")
    test_name_parts("aa", "", "", "aa", "")
    test_name_parts("AA von BB", "AA", "von", "BB", "")
    test_name_parts("AA van der BB", "AA", "van der", "BB", "")
    test_name_parts("von CC, AA", "AA", "von", "CC", "")
    test_name_parts("von CC, aa", "aa", "von", "CC", "")
    test_name_parts("bb, AA", "AA", "", "bb", "")
    test_name_parts("BB,", "", "", "BB", "")
    test_name_parts("von CC Jr, AA", "AA", "von", "CC", "Jr")
  end

  test "should parse with leading von-part" do
    test_name_parts("von Last, First", "First", "von", "Last", "")
  end

  test "should parse leading von-part without comma as last-only" do
    test_name_parts("von Last First", "", "von", "Last First", "")
  end

  test "should parse suffix at end of string" do
    test_name_parts("First Last Jr", "First", "", "Last", "Jr")
  end

  test "should parse suffix in middle of string" do
    test_name_parts("Last Jr, First", "First", "", "Last", "Jr")
  end

  test "should parse last-first" do
    test_name_parts("Last, First", "First", "", "Last", "")
  end

  test "should parse first-last" do
    test_name_parts("First Last", "First", "", "Last", "")
  end

  test "should parse full first-last" do
    test_name_parts("First van der Last", "First", "van der", "Last", "")
  end

  test "should parse full last-first" do
    test_name_parts("von der Last, First, Sr", "First", "von der", "Last", "Sr")
  end
end
