# -*- encoding : utf-8 -*-
require 'test_helper'

class CSLTest < ActiveSupport::TestCase
  test "should create good CSL" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    doc = Document.find_with_fulltext('8e740d30df3f9941e2ca059ef6896830c8a8e226')

    csl = doc.to_csl
    assert_equal 'article-journal', csl['type']
    assert_equal 'Francia', csl['author'][0]['family']
    assert_equal 'Augusto', csl['author'][1]['given']
    assert_equal 'Alleva', csl['author'][2]['family']
    assert_equal 'Handbook of Evolution: The Evolution of Human Societies and Cultures', csl['title']
    assert_equal 'Genes, Brain and Behavior', csl['container-title']
    assert_equal 2005, csl['issued']['date-parts'][0][0]
    assert_equal '4', csl['volume']
    assert_equal '127-128', csl['page']
  end

  test "should create good CSL citations" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    doc = Document.find_with_fulltext('8e740d30df3f9941e2ca059ef6896830c8a8e226')

    cite = doc.to_csl_entry.to_s
    assert_equal "Francia, Nadia, Augusto Vitale, and Enrico Alleva. 2005. “Handbook of Evolution: The Evolution of Human Societies and Cultures”. <i>Genes, Brain and Behavior</i> 4: 127-128.", cite
  end

  test "should be able to specify alternate CSL style files" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    doc = Document.find_with_fulltext('8e740d30df3f9941e2ca059ef6896830c8a8e226')

    assert_equal "Francia, N., Vitale, A., &#38; Alleva, E. (2005). Handbook of Evolution: The Evolution of Human Societies and Cultures. <i>Genes, Brain and Behavior</i>, <i>4</i>, 127-128.", doc.to_csl_entry('apa.csl')
    assert_equal "Francia, Nadia, Augusto Vitale, and Enrico Alleva. 2005. “Handbook of Evolution: The Evolution of Human Societies and Cultures”. <i>Genes, Brain and Behavior</i> 4: 127-128.", doc.to_csl_entry('apsa.csl')
    assert_equal "Francia, Nadia, Augusto Vitale, and Enrico Alleva. 2005. “Handbook of Evolution: The Evolution of Human Societies and Cultures”. <i>Genes, Brain and Behavior</i> 4:127-128.", doc.to_csl_entry('asa.csl')
    assert_equal "Francia, Nadia, Augusto Vitale, and Enrico Alleva. 2005. “Handbook of Evolution: The Evolution of Human Societies and Cultures”. <i>Genes, Brain and Behavior</i> 4: 127-128.", doc.to_csl_entry('chicago-author-date.csl')
    assert_equal "Francia, Nadia, Augusto Vitale, and Enrico Alleva. “Handbook of Evolution: The Evolution of Human Societies and Cultures”. <i>Genes, Brain and Behavior</i> 4 (2005): 127-128.", doc.to_csl_entry('chicago-note-bibliography.csl')
    assert_equal "Francia, N., Vitale, A. &#38; Alleva, E., 2005. Handbook of Evolution: The Evolution of Human Societies and Cultures. <i>Genes, Brain and Behavior</i>, 4, 127-128.", doc.to_csl_entry('harvard1.csl')
    assert_equal "N. Francia, A. Vitale and E. Alleva, “Handbook of Evolution: The Evolution of Human Societies and Cultures”, <i>Genes, Brain and Behavior</i>,  vol. 4, 2005, 127-128.", doc.to_csl_entry('ieee.csl')
    assert_equal "Francia, Nadia, Augusto Vitale, and Enrico Alleva, ‘Handbook of Evolution: The Evolution of Human Societies and Cultures’, <i>Genes, Brain and Behavior</i>, 4 (2005), 127-128.", doc.to_csl_entry('mhra.csl')
    assert_equal "Francia, Nadia, Augusto Vitale, and Enrico Alleva. “Handbook of Evolution: The Evolution of Human Societies and Cultures”. <i>Genes, Brain and Behavior</i> 4 (2005): 127-128. Print.", doc.to_csl_entry('mla.csl')
    assert_equal "Francia, N., Vitale, A. &#38; Alleva, E. Handbook of Evolution: The Evolution of Human Societies and Cultures. <i>Genes, Brain and Behavior</i> <b>4</b>, 127-128 (2005).", doc.to_csl_entry('nature.csl')
    assert_equal "Francia N, Vitale A, Alleva E. Handbook of Evolution: The Evolution of Human Societies and Cultures. Genes, Brain and Behavior 2005;4:127-128.", doc.to_csl_entry('nlm.csl')
    assert_equal "Francia N, Vitale A, Alleva E. Handbook of Evolution: The Evolution of Human Societies and Cultures. Genes, Brain and Behavior. 2005;4:127–8.", doc.to_csl_entry('vancouver.csl')
  end

  test "should be able to fetch CSL styles over HTTP" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    doc = Document.find_with_fulltext('8e740d30df3f9941e2ca059ef6896830c8a8e226')

    cite = doc.to_csl_entry('https://raw.github.com/citation-style-language/styles/master/science.csl').to_s
    assert_equal "N. Francia, A. Vitale, E. Alleva, Handbook of Evolution: The Evolution of Human Societies and Cultures, <i>Genes, Brain and Behavior</i> <b>4</b>, 127-128 (2005).", cite
  end
end
