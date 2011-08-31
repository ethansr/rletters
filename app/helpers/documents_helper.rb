# coding: UTF-8


# Markup helper code for the documents controller.  Primarily extensive code
# to help process Solr faceted browsing queries.
module DocumentsHelper
  
  # Make a link to a page (where num is the *displayed* page number, 1-based).
  # No link will be generated if num == current.  Proper support as well for
  # buttons with optional icons.
  def page_link(text, num, current, button = false, icon = '')
    new_params = params.dup
    new_params[:page] = num - 1
    
    if num == current
      target = "#"
    else
      target = documents_path(new_params)
    end
    
    style = { :class => :paglink, :'data-transition' => :none }
    style[:'data-role'] = :button if button
    style[:'data-inline'] = :true if button
    style[:'data-icon'] = icon unless icon.empty?

    link_to text, target, style
  end

  # Render the pagination links given 'page', 'per_page',
  # and 'num_results'.  We add the pagination to the current params.
  #
  # The way we render (inspired by Flickr):
  #  For 1-8: prev 1 2 3 4 5 6 7 8 9 10 ... N-1 N next
  #  For 9-(N-9): prev 1 2 ... C-3 C-2 C-1 C C+1 C+2 C+3 ... N-1 N next
  #  For (N-8)-end: prev 1 2 ... N-9 N-8 N-7 N-6 N-5 N-4 N-3 N-2 N-1 N next
  def render_pagination(page, per_page, num_results)
    page = Integer(page)
    num_pages = num_results.to_f / per_page.to_f
    num_pages = Integer(num_pages.ceil)
    
    # Previous-page link
    ret = page_link(I18n.t(:'index.previous_button'), page, page + 1, true, 'arrow-l')
    
    # Figure out a set of ranges of numbers we need to draw
    if num_pages < 15
      ranges = [ 1..num_pages ]
    elsif page < 8
      ranges = [ 1..10, num_pages - 1..num_pages ]
    elsif page >= num_pages - 8
      ranges = [ 1..2, num_pages - 9..num_pages ]
    else
      ranges = [ 1..2, page - 2..page + 4, num_pages - 1..num_pages ]
    end
    
    sep = '<span class="pagsep"> &hellip; </span>'.html_safe
    ret += ranges.each { |r| r.to_a.map { |i| page_link(i.to_s, i, page + 1) }.join('') }.join(sep) 
    
    # Next-page link
    ret += page_link(I18n.t(:'index.next_button'), page + 2, page + 1, true, 'arrow-r')
    
    ret.html_safe
  end

  
  # A list of available facets.  We allow faceted browsing on authors,
  # journals, and decade of publication.
  FACETS = [
      { :name => I18n.t(:'filters.authors'), :key => :author, 
        :field => 'authors_facet' },
      { :name => I18n.t(:'filters.journals'), :key => :journal,
        :field => 'journal_facet' },
      { :name => I18n.t(:'filters.pub_date'), :key => :year,
        :field => 'year' }
    ]
  
  # Allow the views to access the FACETS variable.
  def get_facets; FACETS; end
  
  # Construct a link to a faceted browsing page that is the result of taking
  # our current query parameters and adding a facet for <tt>field</tt>
  # set to <tt>val</tt>.  If <tt>link</tt> is specified, use it for the
  # text of the link, otherwise just use the +val+ string.
  def facet_link(field, val, link = nil)
    link = val unless link
    
    new_params = params.dup
    new_params[:fq] ||= []
    new_params[:fq] << %(#{field}:") + val + '"'
    
    link_to link, documents_path(new_params), 'data-transition' => 'none'
  end
  
  # Construct a link to a faceted browsing page that is the result of taking
  # our current query parameters and adding a facet for the +year+ field
  # limiting to the decade beginning with the year <tt>decade</tt>.  If
  # <tt>link</tt> is specified, use it for the text of the link, otherwise
  # just use the +decade+ string.
  def decade_link(decade, link = nil)
    link = decade unless link
    if decade == "1790"
      query = "[* TO 1799]"
    elsif decade == "2010"
      query = "[2010 TO *]"
    else
      last = Integer(decade) + 9
      query = "[#{decade} TO #{last}]"
    end

    new_params = params.dup
    new_params[:fq] ||= []
    new_params[:fq] << "year:#{query}"
    
    link_to link, documents_path(new_params), 'data-transition' => 'none'
  end
  
  
  # Render, as a set of <tt><li></tt> tags, the currently-active Solr facets,
  # as determined by checking <tt>params[:fq]</tt>.  Each of these list
  # elements is, further, a link which will remove the given facet from the
  # set of currently active facets.  Finally, the last item in the list will
  # be a link which allows the user to remove all currently active facets.
  def render_selected_facets
    return "" if params[:fq].blank?
    ret = ""
    
    params[:fq].each do |query|
      arr = query.split(":")
      
      # Get the facet and the value on which we're filtering
      facet = FACETS.find { |f| f[:field] == arr[0] }
      value = arr[1].gsub("\"", "")
      
      # As usual, special filtering to deal with the year string, which is
      # of the format "1900 TO 1909".
      if facet[:field] == 'year'
        parts = value[1..-2].split(" ")
        if parts[0] == '*'
          value = I18n.t(:'filters.pub_date_earlier')
        elsif parts[2] == '*'
          value = I18n.t(:'filters.pub_date_later')
        else
          value = "#{parts[0]}-#{parts[2]}"
        end
      end
      
      # Construct the query without the given facet
      new_params = params.dup
      new_params[:fq].delete(query)
      
      # Create the list item
      ret += content_tag :li, 'data-icon' => 'delete' do
        link_to "#{facet[:name]}: #{value}", documents_path(new_params), 'data-transition' => 'none'
      end
    end
    
    # Strip out all facet parameters
    no_facets_params = params.dup
    no_facets_params.delete(:fq)
    
    # Create the remove all list item
    ret += content_tag :li, 'data-icon' => 'delete' do
      link_to I18n.t(:'filters.remove_all'), documents_path(no_facets_params), 'data-transition' => 'none'
    end
    
    raw(ret)
  end
  
  
  # Render, as a set of <tt><li></tt> items, Solr's faceting results for the
  # given facet.  The +facet+ parameter is one of the facets from
  # <tt>FACETS</tt>.  The +solr_values+ parameter is expected to be the
  # appropriate portion of the Solr query, as returned by our +Document+
  # model this is <tt>@facets[facet[:key]]</tt>.
  #
  # *FIXME* -- Requiring the user to pass in precisely @facets[facet[:key]]
  # seems like a pretty draconian requirement to place on the caller.  Should
  # that get refactored?
  def render_solr_facet(facet, solr_values)
    return "" if solr_values.blank?
    
    ret = ""
    solr_values.each do |key, count|
      # Don't render empty facets (which still get returned by Solr)
      next if count == 0
      
      if facet[:field] == 'year'
        # Translate the Solr key into start and end years
        if key == "*"
          year_start = "*"
          year_end = "1799"
        elsif key == "2010"
          year_start = key
          year_end = "*"
        else
          year_start = key
          year_end = (Integer(year_start) + 9).to_s
        end
        
        # Don't show this facet if it's active
        next if params[:fq] and params[:fq].count("year:[#{year_start} TO #{year_end}]") > 0
        
        # Figure out the correct link text
        if year_start == '*'
          link_text = I18n.t(:'filters.pub_date_earlier')
        elsif year_end == '*'
          link_text = I18n.t(:'filters.pub_date_later')
        else
          link_text = "#{year_start}-#{year_end}"
        end
        
        # Create the link
        link = decade_link key, link_text
      else
        # Don't show this facet if it's active
        next if params[:fq] and params[:fq].count("#{facet[:field]}:\"#{key}\"") > 0
        
        # Create the link
        link_text = key
        link = facet_link facet[:field], key, link_text
      end
      
      # Create a list item
      ret += content_tag(:li) do
        link + " " + content_tag(:span, "#{count}", :class => 'ui-li-count')
      end
    end
    
    raw(ret)
  end
end
