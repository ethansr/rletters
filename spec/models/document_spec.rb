# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Document do
  it_should_behave_like "ActiveModel"
  
  describe '#valid' do
    context "when empty" do
      before(:each) do
        @doc = Document.new
      end
      
      it "isn't valid" do
        @doc.should_not be_valid
      end
    end
    
    context "when a short shasum is specified" do
      before(:each) do
        @doc = Document.new({ "shasum" => "notanshasum" })
      end
      
      it "isn't valid" do
        @doc.should_not be_valid
      end
    end
    
    context "when a bad shasum is specified" do
      before(:each) do
        @doc = Document.new({ "shasum" => "1234567890thisisbad!" })
      end
      
      it "isn't valid" do
        @doc.should_not be_valid
      end
    end
    
    context "when a good shasum is specified" do
      before(:each) do
        @doc = Document.new({ "shasum" => "00972c5123877961056b21aea4177d0dc69c7318" })
      end
      
      it "is valid" do
        @doc.should be_valid
      end
    end
  end
  
  def precise_one_doc
    SolrExamples.stub(:precise_one_doc)
    @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
  end
  
  def fulltext_one_doc
    SolrExamples.stub(:fulltext_one_doc)
    @doc = Document.find_with_fulltext('00972c5123877961056b21aea4177d0dc69c7318')
  end
  
  def precise_all_docs
    SolrExamples.stub(:precise_all_docs)
    @docs = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })
  end
  
  describe ".find" do
    context "when loading one document" do
      before(:each) do
        precise_one_doc
      end
      
      it "loads the document successfully" do
        @doc.should be
      end
    end
    
    context "when Solr fails" do
      before(:each) do
        SolrExamples.stub(:error)
      end
      
      it "raises an exception" do
        expect { Document.find("FAILURE") }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
    
    context "when no documents are returned" do
      before(:each) do
        SolrExamples.stub(:standard_empty_search)
      end
      
      it "raises an exception" do
        expect { Document.find("shatner") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe ".find_with_fulltext" do
    context "when loading one document with fulltext" do
      before(:each) do
        fulltext_one_doc
      end
      
      it "loads the document successfully" do
        @doc.should be
      end
    end
    
    context "when Solr fails" do
      before(:each) do
        SolrExamples.stub(:error)
      end
      
      it "raises an exception" do
        expect { Document.find_with_fulltext("FAILURE") }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
    
    context "when no documents are returned" do
      before(:each) do
        SolrExamples.stub(:standard_empty_search)
      end
      
      it "raises an exception" do
        expect { Document.find_with_fulltext("shatner") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe ".find_all_by_solr_query" do
    context "when loading a set of documents" do
      before(:each) do
        precise_all_docs
      end
      
      it "loads all of the documents" do
        @docs.should have(10).items
      end
    end
    
    context "when Solr fails" do
      before(:each) do
        SolrExamples.stub(:error)
      end
      
      it "raises an exception" do
        expect { Document.find_all_by_solr_query({ :q => "FAILURE", :qt => "standard" }) }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
    
    context "when no documents are returned" do
      before(:each) do
        SolrExamples.stub(:standard_empty_search)
      end
      
      it "returns an empty array" do
        Document.find_all_by_solr_query({ :q => 'shatner', :qt => "standard" }).should have(0).items
      end
    end
  end
  
  describe ".num_results" do
    context "when loading one document" do
      before(:each) do
        precise_one_doc
      end
      
      it "sets num_results to 1" do
        Document.num_results.should eq(1)
      end
    end
    
    context "when loading a set of documents" do
      before(:each) do
        precise_all_docs
      end
      
      it "sets num_results to 10" do
        Document.num_results.should eq(10)
      end
    end
  end
  
  describe ".facets" do
    context "when loading one document with fulltext" do
      before(:each) do
        fulltext_one_doc
      end
      
      it "doesn't load facets if there aren't any" do
        Document.facets.should be_nil
      end
    end
    
    context "when loading a set of documents" do
      before(:each) do
        precise_all_docs
      end
      
      it "sets the facets" do
        Document.facets.should be
      end
      
      it "has the right facet hash keys" do
        Document.facets.should include(:authors_facet)
        Document.facets.should include(:journal_facet)
        Document.facets.should include(:year)
      end
      
      it "parses authors_facet correctly" do
        Document.facets[:authors_facet].assoc('Jennifer L. Snekser')[1].should eq(1)
      end
      
      it "does not include authors_facet entries for authors not present" do
        Document.facets[:authors_facet].assoc('W. Shatner').should_not be
      end
      
      it "parses journal_facet correctly" do
        Document.facets[:journal_facet].assoc('Ethology')[1].should eq(10)
      end
      
      it "does not include journal_facet entries for journals not present" do
        Document.facets[:journal_facet].assoc('Journal of Nothing').should_not be
      end
      
      it "parses year facet queries correctly" do
        Document.facets[:year].assoc('2000–2009')[1].should eq(7)
      end
      
      it "sets year facet queries for non-present years to zero" do
        Document.facets[:year].assoc('1940–1949')[1].should eq(0)
      end
    end
  end
  
  # All of these attributes are loaded in the same loop, so they can be
  # tested at the same time
  describe "attributes" do
    context "when loading one document" do
      before(:each) do
        precise_one_doc
      end
      
      it "gets the right shasum" do
        @doc.shasum.should eq('00972c5123877961056b21aea4177d0dc69c7318')
      end
      
      it "doesn't have any fulltext" do
        @doc.fulltext.should be_nil
      end
    end
    
    context "when loading one document with fulltext" do
      before(:each) do
        fulltext_one_doc
      end
      
      it "gets the right shasum" do
        @doc.shasum.should eq('00972c5123877961056b21aea4177d0dc69c7318')
      end
      
      it "loads the fulltext" do
        @doc.fulltext.should be
      end
    end
    
    context "when loading a set of documents" do
      before(:each) do
        precise_all_docs
      end
      
      it "sets the shasum" do
        @docs[0].shasum.should eq('00040b66948f49c3a6c6c0977530e2014899abf9')
      end
      
      it "sets the doi" do
        @docs[3].doi.should eq('10.1111/j.1439-0310.2009.01716.x')
      end
      
      it "sets the authors" do
        @docs[9].authors.should eq('Troy G. Murphy')
      end
      
      it "sets the title" do
        @docs[2].title.should eq('New Books')
      end
      
      it "sets the journal" do
        @docs[0].journal.should eq('Ethology')
      end
      
      it "sets the year" do
        @docs[5].year.should eq('2001')
      end
      
      it "sets the volume" do
        @docs[7].volume.should eq('104')
      end
      
      it "sets the number" do
        @docs[4].number.should eq('6')
      end
      
      it "sets the pages" do
        @docs[8].pages.should eq('181-187')
      end
      
      it "does not set the fulltext" do
        @docs[1].fulltext.should be_nil
      end
    end
  end
  
  describe "#author_list" do
    context "when loading one document" do
      before(:each) do
        precise_one_doc
      end
      
      it "gets the right number of authors" do
        @doc.author_list.should have(5).items
      end
      
      it "gets the right first author" do
        @doc.author_list[0].should eq("Carlos A. Botero")
      end
      
      it "gets the right fourth author" do
        @doc.author_list[3].should eq("Wesley M. Hochachka")
      end
    end
  end
  
  describe "#formatted_author_list" do
    context "when loading one document" do
      before(:each) do
        precise_one_doc
      end
      
      it "gets the right number of authors" do
        @doc.formatted_author_list.should have(5).items
      end
      
      it "includes the right hash keys" do
        @doc.formatted_author_list[1].should include(:first)
        @doc.formatted_author_list[4].should include(:last)
      end
      
      it "gets the right second author, first name" do
        @doc.formatted_author_list[1][:first].should eq("Andrew E.")
      end
      
      it "gets the right fifth author, last name" do
        @doc.formatted_author_list[4][:last].should eq("Vehrencamp")
      end
    end
  end
  
  describe '#start_page and #end_page' do
    context "when loading one document" do
      before(:each) do
        precise_one_doc
      end
      
      it "parses start_page correctly" do
        @doc.start_page.should eq('1227')
      end
      
      it "parses end_page correctly" do
        @doc.end_page.should eq('1238')
      end
    end
    
    context "when loading a document with funny page ranges" do
      before(:each) do
        @doc = Document.new({ "shasum" => "00972c5123877961056b21aea4177d0dc69c7318", "pages" => "1483-92" })
      end
      
      it "parses start_page correctly" do
        @doc.start_page.should eq('1483')
      end
      
      it "parses end_page correctly" do
        @doc.end_page.should eq('1492')
      end
    end
  end
  
  describe '#term_vectors' do
    context "when loading one document" do
      before(:each) do
        precise_one_doc
      end
      
      it "doesn't set any term vectors" do
        @doc.term_vectors.should be_nil
      end
    end
    
    context "when loading one document with fulltext" do
      before(:each) do
        fulltext_one_doc
      end
      
      it "sets the term vectors" do
        @doc.term_vectors.should be
      end
      
      it "sets tf" do
        @doc.term_vectors["cornell"][:tf].should eq(3)
      end
      
      it "sets offsets" do
        @doc.term_vectors["neurobiology"][:offsets][0].should eq(527...539)
      end
      
      it "sets positions" do
        @doc.term_vectors["reliable"][:positions][0].should eq(2)
      end
      
      it "sets df" do
        @doc.term_vectors["laboratory"][:df].should eq(2)
      end
      
      it "sets tfidf" do
        @doc.term_vectors["humboldt"][:tfidf].should eq(1.0)
      end
      
      it "doesn't set anything for terms that don't appear" do
        @doc.term_vectors["zuzax"].should_not be
      end
    end
  end

end
