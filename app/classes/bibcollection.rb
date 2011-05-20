# coding: UTF-8


# Class which encapsulates the export of a collection of +Document+ instances
# to BibTeX format.
class BIBCollection
  
  # Create a new BibTeX collection.  +documents+ should be an array of 
  # +Document+ objects.
  def initialize(documents)
    @documents = documents
  end
  
  # Convert the array of documents to a string containing the BibTeX records
  # for the entire collection.
  def to_s
    citekeys = []
    ret = ""
    
    @documents.each do |d|
      # We don't have a notion of "cite keys," so just take the first author's
      # last name, stripped of all non-ASCII and spaces, and the year of
      # publication, and uniquify it for the collection.
      citekey = "#{d.formatted_author_list[0][:last].gsub(' ','').gsub(/\P{ASCII}/, '')}#{d.year}"
      while citekeys.include? citekey
        citekey << 'a'
      end
      citekeys << citekey
      
      ret << "@article{#{citekey},\n"
      ret << "    author = {#{d.author_list.join(' and ')}},\n"
      ret << "    title = {#{d.title}},\n"
      ret << "    journal = {#{d.journal}},\n"
      ret << "    volume = {#{d.volume}},\n" unless d.volume.blank?
      ret << "    number = {#{d.number}},\n" unless d.number.blank?
      ret << "    pages = {#{d.pages.gsub('-','--')}},\n" unless d.pages.blank?
      ret << "    doi = {#{d.doi}},\n" unless d.doi.blank?
      ret << "    year = {#{d.year}}\n"
      ret << "}\n"
    end
    
    ret
  end
  
  # Convert to BibTeX and send to the client using the 
  # <tt>controller.send_data</tt> method of an <tt>ActionController.</tt>
  def send(controller)
    controller.send_data to_s, :filename => "export.bib", 
      :type => 'application/x-bibtex', :disposition => 'attachment'
  end
end