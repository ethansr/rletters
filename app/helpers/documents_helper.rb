# coding: UTF-8

module DocumentsHelper
  FACETS = [
      { :name => "Authors", :key => :author, 
        :field => 'authors_facet', :func => :author_link },
      { :name => "Journals", :key => :journal,
        :field => 'journal_facet', :func => :journal_link },
      { :name => "Decade of Publication", :key => :year,
        :field => 'year', :func => :decade_link }
    ]
  
  def get_facets; FACETS; end
  
  # Automatically generate methods for everything but 
  # the 'year' facet
  FACETS.each do |facet|
    next if facet[:field] == 'year'
    class_eval <<-RUBY
    def #{facet[:func].to_s} (val, link = nil)
      link = val unless link
      
      new_params = params.dup
      new_params[:fq] ||= []
      new_params[:fq] << %(#{facet[:field]}:") + val + '"'
      
      link_to link, documents_path(new_params)
    end
    RUBY
  end
  
  def decade_link(decade, link = nil)
    link = decade unless link
    if decade == "1790"
      query = "[* TO 1799]"
    else
      last = Integer(decade) + 9
      query = "[#{decade} TO #{last}]"
    end

    new_params = params.dup
    new_params[:fq] ||= []
    new_params[:fq] << "year:#{query}"
    
    link_to link, documents_path(new_params)
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
  
  
  def render_selected_facets(params)
    return "" if params[:fq].blank?
    ret = ""
    
    params[:fq].each do |query|
      arr = query.split(":")
      
      field = get_facets.find { |f| f[:field] == arr[0] }[:name]
      value = arr[1].gsub("\"", "")
      
      if field == "Decade of Publication"
        parts = value[1..-2].split(" ")
        value = parts[0] == '*' ? "1790s and earlier" : "#{parts[0]}s"
      end
      
      new_params = params.dup
      new_params[:fq].delete(query)
      
      ret += link_to documents_path(new_params), :class => "nowrap", :title => "Remove this search filter" do
        content_tag(:span, "#{field}: #{value}", :class => "facet") +
        content_tag(:span, raw("&nbsp;")) +
        image_tag("x.png", :size => "11x11", :alt => "")
      end
      ret += " "
    end
    
    no_facets_params = params.dup
    no_facets_params.delete(:fq)
    
    ret += link_to documents_path(no_facets_params), :class => "nowrap", :title => "Remove this search filter" do 
      content_tag(:span, "Remove All", :class => "facet") +
      content_tag(:span, raw("&nbsp;")) +
      image_tag("x.png", :size => "11x11", :alt => "")
    end
    
    raw(ret)
  end
  
  def render_solr_facet(params, facet, solr_values)
    return "" if solr_values.blank?
    
    ret = ""
    solr_values.each do |key, count|
      next if count == 0
      
      if facet[:field] == 'year'
        year_start = key
        year_start = "*" if year_start == "1790"
        year_end = (Integer(year_start) + 9).to_s
        year_end = "*" if year_end == "2019"
        
        next if params[:fq] and params[:fq].count("year:[#{year_start} TO #{year_end}]") > 0
        
        link_text = "#{key}s"
        link_text += " and earlier" if key == "1790"
      else
        next if params[:fq] and params[:fq].count("#{facet[:field]}:\"#{key}\"") > 0
        link_text = key
      end
      
      ret += content_tag(:span, :class => "nowrap") do
        method(facet[:func]).call(key, link_text) +
        raw(" (#{count})")
      end
      ret += " "
    end
    
    raw(ret)
  end
end
