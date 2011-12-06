# -*- encoding : utf-8 -*-
require 'minitest_helper'

class NameHelpersTest < ActiveSupport::TestCase

  #
  # Many thanks to Xavier Decoret for this test suite:
  # http://tinyurl.com/6bebaqp
  #
  def call_name_parts(n, first, von, last, suffix)
    ret = NameHelpers.name_parts(n)
    assert_equal first, ret[:first]
    assert_equal von, ret[:von]
    assert_equal last, ret[:last]
    assert_equal suffix, ret[:suffix]
  end

  test "should parse Decoret test suite, abridged" do
    call_name_parts("AA BB", "AA", "", "BB", "")
    call_name_parts("AA", "", "", "AA", "")
    call_name_parts("AA bb", "AA", "", "bb", "")
    call_name_parts("aa", "", "", "aa", "")
    call_name_parts("AA von BB", "AA", "von", "BB", "")
    call_name_parts("AA van der BB", "AA", "van der", "BB", "")
    call_name_parts("von CC, AA", "AA", "von", "CC", "")
    call_name_parts("von CC, aa", "aa", "von", "CC", "")
    call_name_parts("bb, AA", "AA", "", "bb", "")
    call_name_parts("BB,", "", "", "BB", "")
    call_name_parts("von CC Jr, AA", "AA", "von", "CC", "Jr")
  end

  test "should parse with leading von-part" do
    call_name_parts("von Last, First", "First", "von", "Last", "")
  end

  test "should parse leading von-part without comma as last-only" do
    call_name_parts("von Last First", "", "von", "Last First", "")
  end

  test "should parse suffix at end of string" do
    call_name_parts("First Last Jr", "First", "", "Last", "Jr")
  end

  test "should parse suffix in middle of string" do
    call_name_parts("Last Jr, First", "First", "", "Last", "Jr")
  end

  test "should parse last-first" do
    call_name_parts("Last, First", "First", "", "Last", "")
  end

  test "should parse first-last" do
    call_name_parts("First Last", "First", "", "Last", "")
  end

  test "should parse full first-last" do
    call_name_parts("First van der Last", "First", "van der", "Last", "")
  end

  test "should parse full last-first" do
    call_name_parts("von der Last, First, Sr", "First", "von der", "Last", "Sr")
  end
  
  test "should parse broken string that starts w/ comma" do
    call_name_parts(", First", "First", "", "", "")
  end
  
  test "should create simple query for last-only name" do
    assert_equal '"Last"', NameHelpers.name_to_lucene("Last")
  end
  
  test "should create simple query correctly including suffix and von" do
    assert_equal '"van der Last Jr"', NameHelpers.name_to_lucene("van der Last, Jr.")
  end
  
  test "should create correct queries for F Last" do
    ret = NameHelpers.name_to_lucene("F Last")
    
    assert ret.include? '"F* Last"'
  end
  
  test "should create correct queries for FMM Last" do
    ret = NameHelpers.name_to_lucene("FMM Last")
    
    assert ret.include? '"F* Last"'
    assert ret.include? '"F* M* M* Last"'
  end
  
  test "should create correct queries for First Last" do
    ret = NameHelpers.name_to_lucene("First Last")
    
    assert ret.include? '"F Last"'
    assert ret.include? '"First Last"'
  end
  
  test "should create correct queries for First M M Last" do
    ret = NameHelpers.name_to_lucene("First M M Last")
    
    assert ret.include? '"F M* M* Last"'
    assert ret.include? '"First M* M* Last"'
    assert ret.include? '"First Last"'
    assert ret.include? '"F Last"'
  end
  
  test "should create correct queries for First MM Last" do
    ret = NameHelpers.name_to_lucene("First MM Last")

    assert ret.include? '"F M* M* Last"'
    assert ret.include? '"First M* M* Last"'
    assert ret.include? '"First Last"'
    assert ret.include? '"F Last"'
  end
  
  test "should create correct queries for First Middle Middle Last" do
    ret = NameHelpers.name_to_lucene("First Middle Middle Last")
    
    assert ret.include? '"First Last"'
    assert ret.include? '"F Last"'
    assert ret.include? '"First Middle Middle Last"'
    assert ret.include? '"First Middle M Last"'
    assert ret.include? '"First M Middle Last"'
    assert ret.include? '"First M M Last"'
    assert ret.include? '"First MM Last"'
    assert ret.include? '"F Middle Middle Last"'
    assert ret.include? '"F Middle M Last"'
    assert ret.include? '"F M Middle Last"'
    assert ret.include? '"FM Middle Last"'
    assert ret.include? '"F M M Last"'
    assert ret.include? '"FMM Last"'
  end
end
