module DocumentsHelper
  def author_link(author, link = nil)
    link = author if link.nil? 
    link_to link, documents_path(:fq => "author_facet:\"#{author}\"")
  end
  
  def authors_link(authors)
    raw(authors.split(',').map(&method(:author_link)).join(", "))
  end
  
  def journal_link(journal)
    link_to journal, documents_path(:fq => "journal_facet:\"#{journal}\"")
  end
  
  def decade_link(decade, link = nil)
    link = decade if link.nil?
    if decade == "1790"
      query = "[* TO 1799]"
    else
      last = Integer(decade) + 9
      query = "[#{decade} TO #{last}]"
    end
    link_to link, documents_path(:fq => "year:#{query}")
  end
end
