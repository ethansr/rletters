# -*- encoding : utf-8 -*-
require 'test_helper'

class MODSTest < ActiveSupport::TestCase
  test "should create good MODS documents" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    xml = doc.to_mods
    
    # This test is incomplete, but we'll validate the schema in the next test
    assert_equal "How Reliable are the Methods for Estimating Repertoire Size?", \
      xml.elements['mods/titleInfo/title'].text
    assert_equal "Carlos A.", xml.elements['mods/name/namePart'].text
    assert_equal "2008", xml.elements['mods/originInfo/dateIssued'].text
    assert_equal "Ethology", xml.elements['mods/relatedItem/titleInfo/title'].text
    assert_equal "2008", xml.elements['mods/relatedItem/originInfo/dateIssued'].text
    assert_equal "114", xml.elements['mods/relatedItem/part/detail/number'].text
    assert_equal "1227", xml.elements['mods/relatedItem/part/extent/start'].text
    assert_equal "2008", xml.elements['mods/relatedItem/part/date'].text
    assert_equal "10.1111/j.1439-0310.2008.01576.x", xml.elements['mods/identifier'].text
  end
  
  test "should create good MODS collections" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    arr = [doc, doc]
    
    xml = arr.to_mods
    assert_equal "How Reliable are the Methods for Estimating Repertoire Size?", \
      xml.elements['modsCollection/mods[1]/titleInfo/title'].text
    assert_equal 2, xml.elements['modsCollection'].elements.size
  end

  test "should validate MODS against the schema" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    rexml_doc = doc.to_mods
    xml_str = ''
    rexml_doc.write(xml_str)
    
    noko_doc = Nokogiri::XML::Document.parse(xml_str)
    xsd = Nokogiri::XML::Schema(File.read(Rails.root.join('test', 'unit', 'serializers', 'mods-3-4.xsd')))
    
    errors = xsd.validate(noko_doc)
    if errors.length != 0
      flunk errors[0].to_s
    end
  end
  
  test "should validate MODS collection against the schema" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    # Hack into the doc class, because the schema actually checks unique IDs
    doc2 = Marshal.load(Marshal.dump(doc))
    doc2.instance_variable_set(:@shasum, 'wut')
    
    arr = [doc, doc2]
    
    rexml_doc = arr.to_mods
    xml_str = ''
    rexml_doc.write(xml_str)
    
    noko_doc = Nokogiri::XML::Document.parse(xml_str)
    xsd = Nokogiri::XML::Schema(File.read(Rails.root.join('test', 'unit', 'serializers', 'mods-3-4.xsd')))
    
    errors = xsd.validate(noko_doc)
    if errors.length != 0
      flunk errors[0].to_s
    end
  end
end
