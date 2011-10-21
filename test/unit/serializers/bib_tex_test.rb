# -*- encoding : utf-8 -*-
require 'test_helper'

class BibTexTest < ActiveSupport::TestCase
  test "should create good BibTeX" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    str = doc.to_bibtex
    assert str.start_with? "@article{Botero2008,"
    assert str.include? "author = {Carlos A. Botero and Andrew E. Mudge and Amanda M. Koltz and Wesley M. Hochachka and Sandra L. Vehrencamp}"
    assert str.include? "title = {How Reliable are the Methods for Estimating Repertoire Size?}"
    assert str.include? "journal = {Ethology}"
    assert str.include? "volume = {114}"
    assert str.include? "pages = {1227-1238}"
    assert str.include? "doi = {10.1111/j.1439-0310.2008.01576.x}"
    assert str.include? "year = {2008}"
  end
  
  test "should create BibTeX for array" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    arr = [doc, doc]
    
    str = arr.to_bibtex
    assert str.start_with? "@article{Botero2008,"
    assert str.include? "}\n@article{Botero2008,"
  end
end
