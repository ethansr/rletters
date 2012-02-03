# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::BibTex do
  
  context "when serializing a single document" do
    before(:each) do
      Examples.stub_with(/localhost/, :precise_one_doc)
      @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      @str = @doc.to_bibtex
    end
    
    it "creates good BibTeX" do
      @str.should be_start_with("@article{Botero2008,")
      @str.should include("author = {Carlos A. Botero and Andrew E. Mudge and Amanda M. Koltz and Wesley M. Hochachka and Sandra L. Vehrencamp}")
      @str.should include("title = {How Reliable are the Methods for Estimating Repertoire Size?}")
      @str.should include("journal = {Ethology}")
      @str.should include("volume = {114}")
      @str.should include("pages = {1227-1238}")
      @str.should include("doi = {10.1111/j.1439-0310.2008.01576.x}")
      @str.should include("year = {2008}")
    end
  end
  
  context "when serializing an array of documents" do
    before(:each) do
      Examples.stub_with(/localhost/, :precise_one_doc)
      doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      @docs = [ doc, doc ]
      @str = @docs.to_bibtex
    end
    
    it "creates good BibTeX" do
      @str.should be_start_with("@article{Botero2008,")
      @str.should include("}\n@article{Botero2008,")
    end
  end
  
  context "when serializing an anonymous document" do
    before(:each) do
      Examples.stub_with(/localhost/, :precise_one_doc)
      @doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
      @doc.instance_variable_set(:@author, nil)
      @doc.instance_variable_set(:@author_list, nil)
      @doc.instance_variable_set(:@formatted_author_list, nil)
      @str = @doc.to_bibtex
    end
    
    it "creates cite keys correctly" do
      @str.should be_start_with("@article{Anon2008,")
    end
  end
end
