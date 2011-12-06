# -*- encoding : utf-8 -*-
require 'minitest_helper'

class RISTest < ActiveSupport::TestCase
  test "should create good RIS" do
    SolrExamples.stub(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    str = doc.to_ris
    assert str.start_with? "TY  - JOUR\n"
    assert str.include? "AU  - Botero,Carlos A."
    assert str.include? "AU  - Mudge,Andrew E."
    assert str.include? "AU  - Koltz,Amanda M."
    assert str.include? "AU  - Hochachka,Wesley M."
    assert str.include? "AU  - Vehrencamp,Sandra L."
    assert str.include? "TI  - How Reliable are the Methods for Estimating Repertoire Size?"
    assert str.include? "JO  - Ethology"
    assert str.include? "VL  - 114"
    assert str.include? "SP  - 1227"
    assert str.include? "EP  - 1238"
    assert str.include? "PY  - 2008"
    assert str.end_with? "ER  - \n"
  end
  
  test "should create RIS for array" do
    SolrExamples.stub(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    arr = [doc, doc]
    
    str = arr.to_ris
    assert str.start_with? "TY  - JOUR\n"
    assert str.include? "ER  - \nTY  - JOUR\n"
  end
end
