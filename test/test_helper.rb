# -*- coding: utf-8 -*-
ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start 'rails' do
  coverage_dir('doc/coverage')
end

require File.expand_path('../../config/environment', __FILE__)
require 'test/unit'
require 'mocha'
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  # Stub out the Solr connection
  def stub_solr_response(solr_response)
    Document.stubs(:get_solr_response).returns(solr_response)
  end
end

# "Fixtures" for Solr responses that we can use throughout tests
SOLR_RESPONSE_ERROR = {}
SOLR_RESPONSE_EMPTY = { 'response' => { 'numFound' => 0, 'start' => 0, 'docs' => [] } }
SOLR_RESPONSE_VALID = { 'response' => { 
    'numFound' => 5, 'start' => 0, 'docs' => 
    [ { 'shasum' => '8e740d30df3f9941e2ca059ef6896830c8a8e226', 'doi' => '10.1111/j.1601-183X.2005.00114.x',
        'authors' => 'Nadia Francia, Augusto Vitale, Enrico Alleva',
        'title' => 'Handbook of Evolution: The Evolution of Human Societies and Cultures',
        'journal' => 'Genes, Brain and Behavior',
        'year' => '2005',
        'volume' => '4',
        'pages' => '127-128',
        'fulltext' => 'Handbook of Evolution: The Evolution of Human Societies and Cultures
F. M. Wuketits and C. Antweiler (eds)
Wiley-VCH Verlag GmbH & Co. KGaA, Weinheim, 2004. $ 240 (hardcover), 341 pp. ISBN 3-527-30839-3' },
      { 'shasum' => 'a10412fa4794d7b44d6a848995de0b8143b06dd1', 'doi' => '10.1046/j.1439-0310.2001.0656a.x',
        'authors' => 'T. M. Freeberg',
        'title' => 'The Ontogeny of Information: Developmental Systems and Evolution & Evolution\'s Eye: A Systems View of the Biology-Culture Divide',
        'journal' => 'Ethology',
        'year' => '2001',
        'volume' => '107',
        'pages' => '277-279',
        'fulltext' => 'Oyama, S. 2000: The Ontogeny of Information: Developmental Systems and Evolution, 2nd edition. Duke University Press, Durham, North Carolina. 273 pp., Pb US$ 19.95, ISBN 0-8223-2466-0. Oyama, S. 2000: Evolution\'s Eye: A Systems View of the Biology-Culture Divide. Duke University Press, Durham, North Carolina. 274 pp., Pb $18.95, ISBN 0-8223-2472-5.' },
      { 'shasum' => '013275fd04e96643930cc144eb64cb8d20087491', 'doi' => '10.1111/j.1601-183X.2005.00156.x',
        'authors' => 'M. L. Scattoni, E. Alleva',
        'title' => 'David C. Geary: The origin of mind: evolution of brain, cognition and general intelligence',
        'journal' => 'Genes, Brain and Behavior',
        'year' => '2006',
        'volume' => '5',
        'pages' => '205-206',
        'fulltext' => 'Book review
The origin of mind: evolution of brain, cognition and general intelligence
David C. Geary
David C. Geary, Department Chair and Professor of Psychological Sciences at the University of Missouri, attempts a comprehensive overview of recent findings on brain' },
      { 'shasum'=>'7ecdcd1ca5a4345ba103cc3fe06a92c0e5ef7ca9',
	 'doi'=>'10.1111/j.1601-183X.2009.00489.x',
	 'authors'=>'F. Ali, R. Meier',
	 'title'=>'
              Primate home range and
              GRIN2A
              , a receptor gene involved in neuronal plasticity: implications for the evolution of spatial memory
            ',
	 'journal'=>'Genes, Brain and Behavior',
	 'year'=>'2009',
	 'volume'=>'8',
	 'pages'=>'435-441',
	 'fulltext'=>'\ufeffGenes, Brain and Behavior
Official publication of the International Behavioural and Neural Genetics Society
Genes, Brain and Behavior (2009) 8: 435-441
© 2009 The Authors
Journal compilation © 2009 Blackwell Publishing Ltd/International Behavioural and Neural Genetics Society
Primate home range and GRIN2A, a receptor gene involved in neuronal plasticity: implications for the evolution' },
      {
	 'shasum'=>'ef1522704c94b7e6d55f5c024bc2f135a8d67286',
	 'doi'=>'10.1111/j.1601-183X.2010.00610.x',
	 'authors'=>'J. Fischer, K. Hammerschmidt',
	 'title'=>'Ultrasonic vocalizations in mouse models for speech and socio-cognitive disorders: insights into the evolution of vocal communication',
	 'journal'=>'Genes, Brain and Behavior',
	 'year'=>'2011',
	 'volume'=>'10',
	 'pages'=>'17-27',
	 'fulltext'=>'\ufeffGenes, Brain Linj Behavior
Official publication of the International Behavioural and Neural Genetics Society
Genes, BrainandBehavior(2011) 10: 17-27	doi: 10.1111/j.1601-183X.2010.00610.x
Review
Ultrasonic vocalizations in mouse models for speech and socio-cognitive disorders: insights into the evolution of vocal communication
J. Fischer*-1-* and K. Hammerschmidt*' } ] },
  'facet_counts' => {
    'facet_queries' => {
      'year:[* TO 1799]' => 0, 'year:[1800 TO 1809]' => 0, 'year:[1810 TO 1819]' => 0, 'year:[1820 TO 1829]' => 0,
      'year:[1830 TO 1839]' => 0, 'year:[1840 TO 1849]' => 0, 'year:[1850 TO 1859]' => 0, 'year:[1860 TO 1869]' => 0,
      'year:[1870 TO 1879]' => 0, 'year:[1880 TO 1889]' => 0, 'year:[1890 TO 1899]' => 0, 'year:[1900 TO 1909]' => 0,
      'year:[1910 TO 1919]' => 0, 'year:[1920 TO 1929]' => 0, 'year:[1930 TO 1939]' => 0, 'year:[1940 TO 1949]' => 0,
      'year:[1950 TO 1959]' => 0, 'year:[1960 TO 1969]' => 0, 'year:[1970 TO 1979]' => 0, 'year:[1980 TO 1989]' => 0,
      'year:[1990 TO 1999]' => 5, 'year:[2000 TO 2009]' => 25, 'year:[2010 TO *]' => 3},
    'facet_fields'=>{
      'authors_facet' => [
                          'Augusto Vitale', 2,
                          'Enrico Alleva', 2,
                          'Magnus Enquist', 2,
                          'Nadia Francia', 2,
                          'Adolfo Amézquita', 1,
                          'Alexandra L. Basolo', 1,
                          'Amanda Seed', 1,
                          'Andrew N. Iwaniuk', 1,
                          'Bert Hölldobler', 1,
                          'Bjorn Forkman', 1],
      'journal_facet' => [
                          'Ethology', 28,
                          'Genes, Brain and Behavior', 5]},
    'facet_dates' => {}}}


