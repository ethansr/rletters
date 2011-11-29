# -*- encoding : utf-8 -*-
require 'test_helper'

class CSLTest < ActiveSupport::TestCase
  test "should create good CSL" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')

    csl = doc.to_csl
    assert_equal 'article-journal', csl['type']
    assert_equal 'Botero', csl['author'][0]['family']
    assert_equal 'Andrew E.', csl['author'][1]['given']
    assert_equal 'Koltz', csl['author'][2]['family']
    assert_equal 'How Reliable are the Methods for Estimating Repertoire Size?', csl['title']
    assert_equal 'Ethology', csl['container-title']
    assert_equal 2008, csl['issued']['date-parts'][0][0]
    assert_equal '114', csl['volume']
    assert_equal '1227-1238', csl['page']
  end

  test "should create good CSL citations" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')

    cite = doc.to_csl_entry.to_s
    assert_equal "Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.", cite
  end

  test "should be able to specify alternate CSL style files" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')

    assert_equal "Botero, C. A., Mudge, A. E., Koltz, A. M., Hochachka, W. M., &#38; Vehrencamp, S. L. (2008). How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i>, <i>114</i>, 1227-1238.", doc.to_csl_entry('apa.csl')
    assert_equal "Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.", doc.to_csl_entry('apsa.csl')
    assert_equal "Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114:1227-1238.", doc.to_csl_entry('asa.csl')
    assert_equal "Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.", doc.to_csl_entry('chicago-author-date.csl')
    assert_equal "Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114 (2008): 1227-1238.", doc.to_csl_entry('chicago-note-bibliography.csl')
    assert_equal "Botero, C.A., Mudge, A.E., Koltz, A.M., Hochachka, W.M. &#38; Vehrencamp, S.L., 2008. How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i>, 114, 1227-1238.", doc.to_csl_entry('harvard1.csl')
    assert_equal "C.A. Botero, A.E. Mudge, A.M. Koltz, W.M. Hochachka and S.L. Vehrencamp, “How Reliable are the Methods for Estimating Repertoire Size?”, <i>Ethology</i>,  vol. 114, 2008, 1227-1238.", doc.to_csl_entry('ieee.csl')
    assert_equal "Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp, ‘How Reliable Are the Methods For Estimating Repertoire Size?’, <i>Ethology</i>, 114 (2008), 1227-1238.", doc.to_csl_entry('mhra.csl')
    assert_equal "Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114 (2008): 1227-1238. Print.", doc.to_csl_entry('mla.csl')
    assert_equal "Botero, C.A., Mudge, A.E., Koltz, A.M., Hochachka, W.M. &#38; Vehrencamp, S.L. How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i> <b>114</b>, 1227-1238 (2008).", doc.to_csl_entry('nature.csl')
    assert_equal "Botero CA, Mudge AE, Koltz AM, Hochachka WM, Vehrencamp SL. How Reliable are the Methods for Estimating Repertoire Size?. Ethology 2008;114:1227-1238.", doc.to_csl_entry('nlm.csl')
    assert_equal "Botero CA, Mudge AE, Koltz AM, Hochachka WM, Vehrencamp SL. How Reliable are the Methods for Estimating Repertoire Size?. Ethology. 2008;114:1227–38.", doc.to_csl_entry('vancouver.csl')
  end

  test "should be able to fetch CSL styles over HTTP" do
    stub_solr_response(:precise_one_doc)
    stub_request(:get, 'https://raw.github.com/citation-style-language/styles/master/science.csl').to_return(ResponseExamples.load(:csl_response_science))

    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    cite = doc.to_csl_entry('https://raw.github.com/citation-style-language/styles/master/science.csl').to_s
    assert_equal "C. A. Botero, A. E. Mudge, A. M. Koltz, W. M. Hochachka, S. L. Vehrencamp, How Reliable are the Methods for Estimating Repertoire Size?, <i>Ethology</i> <b>114</b>, 1227-1238 (2008).", cite
  end
end
