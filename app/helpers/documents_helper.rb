# coding: UTF-8

module DocumentsHelper
  def author_link(author, link = nil)
    link = author unless link
    link_to link, documents_path(:add_facet => "authors_facet:\"#{author}\"")
  end
  
  def authors_link(authors)
    raw(authors.split(',').map{ |a| author_link a }.join(", "))
  end
  
  def journal_link(journal, link = nil)
    link = journal unless link
    link_to link, documents_path(:add_facet => "journal_facet:\"#{journal}\"")
  end
  
  def decade_link(decade, link = nil)
    link = decade unless link
    if decade == "1790"
      query = "[* TO 1799]"
    else
      last = Integer(decade) + 9
      query = "[#{decade} TO #{last}]"
    end
    link_to link, documents_path(:add_facet => "year:#{query}")
  end
  
  def year_link(year, link = nil)
    link = year unless link
    if Integer(year) <= 1799
      decade = "1790"
    elsif Integer(year) > 2010
      decade = "2010"
    else
      decade = ((Float(year) / 10.0).floor * 10).to_s
    end
    decade_link decade, link
  end
  
  def selected_facets_list(facets)
    remove_all_link = link_to documents_path(:remove_facet => "all"), :class => "nowrap" do
      raw("Remove All ") +
      content_tag(:span, "", :class => "icon cross")
    end
    
    facets.map { |facet|
      arr = facet.split(":")
      field_map = { "year" => "Year", "authors_facet" => "Author", 
        "journal_facet" => "Journal" }
      field = field_map[arr[0]]
      value = arr[1].gsub("\"", "")
      
      if field == "Year"
        parts = value[1..-2].split(" ")
        parts[0] = "∞" if parts[0] == "*"
        parts[2] = "∞" if parts[1] == "*"
        value = "#{parts[0]}–#{parts[2]}"
      end
      
      link_to documents_path(:remove_facet => facet), :class => "nowrap" do
        raw("#{field}: #{value} ") +
        content_tag(:span, "", :class => "icon cross")
      end
    }.push(remove_all_link)
  end
  
  def facet_value_list(facet, field)
    ret = []
    facet.each do |k, c|
      next if c == 0
      if field == "year"
        ys = k
        ys = "*" if ys == "1790"
        ye = (Integer(ys) + 9).to_s
        ye = "*" if ye == "2019"
        next if session[:facets].count("year:[#{ys} TO #{ye}]") > 0
        
        link = "#{k}s"
        link = "#{k}s and earlier" if k == "1790"
      else
        next if session[:facets].count("#{field}:\"#{k}\"") > 0
        link = k
      end
      
      ret << { :value => k, :count => c, :link => link }
    end
    ret
  end
  
  def get_facets
    [
      { :name => "Authors", :key => :author, 
        :field => 'authors_facet', :func => method(:author_link) },
      { :name => "Journals", :key => :journal,
        :field => 'journal_facet', :func => method(:journal_link) },
      { :name => "Decade of Publication", :key => :year,
        :field => 'year', :func => method(:decade_link) }
    ]
  end
end
