# -*- encoding : utf-8 -*-
require 'test_helper'

class MarcTest < ActiveSupport::TestCase
  test "should create good MARC::Records" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    record = doc.to_marc
    
    # Control fields
    assert_equal '00972c5123877961056b21aea4177d0dc69c7318', record['001'].value
    assert_equal 'PDFSHASUM', record['003'].value
    assert_equal '110501s2008       ||||fo     ||0 0|eng d', record['008'].value
    assert_equal 'RLetters', record['040']['a']
    assert_equal 'eng', record['040']['b']
    assert_equal 'RLetters', record['040']['c']
    
    # DOI field
    # Standard identifier type: stored in $2
    assert_equal '7', record['024'].indicator1
    assert_equal 'doi', record['024']['2']
    assert_equal '10.1111/j.1439-0310.2008.01576.x', record['024']['a']
    
    # First author field
    # Name is in Last, First format
    assert_equal '1', record['100'].indicator1
    assert_equal 'Botero, Carlos A.', record['100']['a']
    
    # All author fields
    good = [ 'Botero, Carlos A.', 'Mudge, Andrew E.', 'Koltz, Amanda M.',
      'Hochachka, Wesley M.', 'Vehrencamp, Sandra L.' ]
    record.find_all {|field| field.tag == '700' }.each do |f|
      # Name is in Last, First format
      assert_equal '1', f.indicator1
      assert good.include? f['a']
    end
    
    # Title field
    # This is the entire title, no further information
    assert_equal '1', record['245'].indicator1
    # This field ends with a period, even when other punctuation is
    # also present
    assert_equal 'How Reliable are the Methods for Estimating Repertoire Size?.', record['245']['a']
    
    # Journal, volume and/or number field
    # We also have an 830 entry to indicate the series
    assert_equal '1', record['490'].indicator1
    assert_equal 'Ethology', record['490']['a']
    assert_equal 'v. 114', record['490']['v']
    # Don't guess at non-filing characters
    assert_equal '0', record['830'].indicator2
    assert_equal 'Ethology', record['830']['a']
    assert_equal 'v. 114', record['830']['v']
    
    # "Host Item Entry" field (free-form citation data)
    # Do display this connection
    assert_equal '0', record['773'].indicator1
    assert_equal 'Ethology', record['773']['t']
    # The "related parts" entry, used for the full journal citation
    assert_equal 'Vol. 114 (2008), p. 1227-1238', record['773']['g']
    # An abbreviated form of the same
    assert_equal '114<1227', record['773']['q']
    # Specify this is a serial, not a human name of any sort
    assert_equal 'nnas', record['773']['7']
    
    # Detailed date and sequence information
    # Volume
    assert_equal '114', record['363']['a']
    # FIXME: What do we do in the case of not having a number?  Should the
    # start page be listed in 'b'?
    assert_equal '1227', record['363']['c']
    assert_equal '2008', record['363']['i']
    
    # Date record
    # Date is properly formatted
    assert_equal '0', record['362'].indicator1
    # Always ends with a period, since we do not express date ranges
    assert_equal '2008.', record['362']['a']
  end
end
