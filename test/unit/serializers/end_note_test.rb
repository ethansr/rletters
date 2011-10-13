# -*- encoding : utf-8 -*-
require 'test_helper'

class EndNoteTest < ActiveSupport::TestCase
  test "should create good EndNote" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    str = doc.to_endnote
    assert str.start_with? "%0 Journal Article\n"
    assert str.include? "%A Botero, Carlos A."
    assert str.include? "%A Mudge, Andrew E."
    assert str.include? "%A Koltz, Amanda M."
    assert str.include? "%A Hochachka, Wesley M."
    assert str.include? "%A Vehrencamp, Sandra L."
    assert str.include? "%T How Reliable are the Methods for Estimating Repertoire Size?"
    assert str.include? "%J Ethology"
    assert str.include? "%V 114"
    assert str.include? "%P 1227-1238"
    assert str.include? "%M 10.1111/j.1439-0310.2008.01576.x"
    assert str.include? "%D 2008"
    # This extra carriage return is the item separator, and is thus very 
    # important
    assert str.end_with? "\n\n"
  end
end
