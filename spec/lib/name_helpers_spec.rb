# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:lib' if ENV["COVERAGE"] && RUBY_VERSION >= "1.9.0"

describe NameHelpers do
  
  describe '.name_parts' do
    
    context 'when running the Decoret test suite (abridged)' do
      #
      # Many thanks to Xavier Decoret for this test suite:
      # http://tinyurl.com/6bebaqp
      #
      
      it "should pass all tests" do
        NameHelpers.name_parts("AA BB").should be_name_parts("AA", "", "BB", "")
        NameHelpers.name_parts("AA").should be_name_parts("", "", "AA", "")
        NameHelpers.name_parts("AA bb").should be_name_parts("AA", "", "bb", "")
        NameHelpers.name_parts("aa").should be_name_parts("", "", "aa", "")
        NameHelpers.name_parts("AA von BB").should be_name_parts("AA", "von", "BB", "")
        NameHelpers.name_parts("AA van der BB").should be_name_parts("AA", "van der", "BB", "")
        NameHelpers.name_parts("von CC, AA").should be_name_parts("AA", "von", "CC", "")
        NameHelpers.name_parts("von CC, aa").should be_name_parts("aa", "von", "CC", "")
        NameHelpers.name_parts("bb, AA").should be_name_parts("AA", "", "bb", "")
        NameHelpers.name_parts("BB,").should be_name_parts("", "", "BB", "")
        NameHelpers.name_parts("von CC Jr, AA").should be_name_parts("AA", "von", "CC", "Jr")
      end
    end
    
    it "parses name with leading von-part" do
      NameHelpers.name_parts("von Last, First").should be_name_parts("First", "von", "Last", "")
    end

    it "parses leading von-part without comma as last-only" do
      NameHelpers.name_parts("von Last First").should be_name_parts("", "von", "Last First", "")
    end

    it "parses suffix at end of string" do
      NameHelpers.name_parts("First Last Jr").should be_name_parts("First", "", "Last", "Jr")
    end

    it "parses suffix in middle of string" do
      NameHelpers.name_parts("Last Jr, First").should be_name_parts("First", "", "Last", "Jr")
    end

    it "parses last-first" do
      NameHelpers.name_parts("Last, First").should be_name_parts("First", "", "Last", "")
    end

    it "parses first-last" do
      NameHelpers.name_parts("First Last").should be_name_parts("First", "", "Last", "")
    end

    it "parses full first-last" do
      NameHelpers.name_parts("First van der Last").should be_name_parts("First", "van der", "Last", "")
    end

    it "parses full last-first" do
      NameHelpers.name_parts("von der Last, First, Sr").should be_name_parts("First", "von der", "Last", "Sr")
    end

    it "parses broken string that starts with a comma" do
      NameHelpers.name_parts(", First").should be_name_parts("First", "", "", "")
    end
  end
  
  describe '.name_to_lucene' do    
    it "creates simple query for last-only name" do
      expected = [ "Last" ]
      NameHelpers.name_to_lucene("Last").should be_lucene_query(expected)
    end

    it "creates simple query correctly including suffix and von" do
      expected = [ "van der Last Jr" ]
      NameHelpers.name_to_lucene("van der Last, Jr.").should be_lucene_query(expected)
    end

    it "creates correct queries for F Last" do
      expected = [ "F* Last" ]
      NameHelpers.name_to_lucene("F Last").should be_lucene_query(expected)
    end

    it "creates correct queries for FMM Last" do
      expected = [ "F* Last", "F* M* M* Last" ]
      NameHelpers.name_to_lucene("FMM Last").should be_lucene_query(expected)
    end

    it "creates correct queries for First Last" do
      expected = [ "F Last", "First Last" ]
      NameHelpers.name_to_lucene("First Last").should be_lucene_query(expected)
    end

    it "creates correct queries for First M M Last" do
      expected = [ "F M* M* Last", "First M* M* Last", "First Last", 
        "F Last" ]
      NameHelpers.name_to_lucene("First M M Last").should be_lucene_query(expected)
    end

    it "creates correct queries for First MM Last" do
      expected = [ "F M* M* Last", "First M* M* Last", "First Last", 
        "F Last" ]
      NameHelpers.name_to_lucene("First MM Last").should be_lucene_query(expected)
    end

    it "creates correct queries for First Middle Middle Last" do
      expected = [ "First Last", "F Last", "First Middle Middle Last", 
        "First Middle M Last", "First M Middle Last", "First M M Last",
        "First MM Last", "F Middle Middle Last", "F Middle M Last",
        "F M Middle Last", "FM Middle Last", "F M M Last", "FMM Last",
        "FM M Last", "F MM Last" ]
      NameHelpers.name_to_lucene("First Middle Middle Last").should be_lucene_query(expected)
    end    
  end
  
end
