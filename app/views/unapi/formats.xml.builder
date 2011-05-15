xml.instruct!

opts = {}
opts[:id] = params[:id] unless params[:id].blank?
xml.formats(opts) {
  xml.format(:name => 'bibtex', :type => 'application/x-bibtex', :docs => 'http://mirrors.ctan.org/biblio/bibtex/contrib/doc/btxdoc.pdf')
  xml.format(:name => 'ris', :type => 'application/x-research-info-systems', :docs => 'http://www.refman.com/support/risformat_intro.asp')
  xml.format(:name => 'endnote', :type => 'application/x-endnote-refer', :docs => 'http://auditorymodels.org/jba/bibs/NetBib/Tools/bp-0.2.97/doc/endnote.html')
  xml.format(:name => 'rdf', :type => 'application/rdf+xml', :docs => 'http://www.w3.org/TR/rdf-syntax-grammar/')
  xml.format(:name => 'turtle', :type => 'text/turtle', :docs => 'http://www.w3.org/TeamSubmission/turtle/')
  xml.format(:name => 'marcxml', :type => 'application/marcxml+xml', :docs => 'http://www.loc.gov/standards/marcxml/')
  xml.format(:name => 'marc', :type => 'application/marc', :docs => 'http://www.loc.gov/marc/')
  xml.format(:name => 'mods', :type => 'application/mods+xml', :docs => 'http://www.loc.gov/standards/mods/')
}
