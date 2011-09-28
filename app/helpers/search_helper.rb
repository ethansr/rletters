# -*- encoding : utf-8 -*-

module SearchHelper
  # Return a formatted version of the number of documents in the last search
  # @return [String] number of documents in the last search
  def num_results_string
    if params[:precise] or params[:q] or params[:fq]
      ret = "#{pluralize(Document.num_results, 'document')} found"
    else
      ret = "#{pluralize(Document.num_results, 'document')} in database"
    end
    ret
  end

  # Convert from a facet query (fq parameter) to a three-tuple
  #
  # Our internal format for facet parsing is a 3-tuple, <tt>[:symbol, value,
  # count]</tt>.  Solr facets (as found in +params+) are an array of strings
  # of the format +field:query+, and are more complicated than that
  # (+year:[start TO end]+) for the +:year+ facet.  This function takes a Solr
  # query parameter and returns a three-tuple value.  Notably, Solr query
  # parameters lack the +count+ value, so it will be set to zero.
  #
  # This function is used to parse the current facet query parameters and 
  # return the active facets in a format which we can use.
  #
  # @param [String] fq Solr facet query to convert
  # @return [Array] +[:symbol, value, 0]+ representation of facet
  def fq_to_facet(fq)
    # Facet query parameters are of the form 'field:query'
    parts = fq.split(':')
    return [''.to_sym, '', count] unless parts.count == 2

    field = parts[0]
    query = parts[1]

    # Strip quotes from the query if present
    query = query[1..-2] if query[0] == "\"" and query[query.length - 1] == "\""

    # If the field isn't 'year', we're done here
    return [field.to_sym, query, 0] unless field == 'year'

    # We need to parse the decade query if it's 'year'
    decade = query[1..-2].split[0]
    if decade == '*'
      decade = '1790s'
    else
      decade << 's'
    end
    return [field.to_sym, decade, 0]
  end

  # Convert from a three-tuple to a facet query (fq parameter)
  #
  # Our internal format for facet parsing is a 3-tuple, <tt>[:symbol, value,
  # count]</tt>.  Solr facets (as found in +params+) are an array of strings
  # of the format +field:query+, and are more complicated than that
  # (+year:[start TO end]+) for the +:year+ facet.  This function takes a
  # three-tuple and returns a Solr facet query string.
  #
  # This function is used to generate the links for adding new facets to
  # the current query.
  #
  # @param [Array] facet +[:symbol, value, count]+ to convert
  # @return [String] Solr facet query representation of facet
  def facet_to_fq(facet)
    # Unless the field is year, we're done
    return "#{facet[0].to_s}:\"#{facet[1]}\"" unless facet[0] == :year

    # Convert from a decade to a query
    decade = facet[1][0..-2]
    if decade == "1790"
      query = "[* TO 1799]"
    elsif decade == "2010"
      query = "[2010 TO *]"
    else
      last = Integer(decade) + 9
      query = "[#{decade} TO #{last}]"
    end

    return "year:#{query}"
  end

  # Create a link to the given set of facets
  #
  # This function converts an array of our three-tuple facet values to a link
  # (generated via +link_to+) to the search page for that filtered query.  All
  # parameters other than +:fq+ are simply duplicated (including the search
  # query itself, +:q+).
  #
  # @param [String] text body of the link
  # @param [Array] facets array of 3-tuple facet values, possibly empty
  # @return [ActiveSupport::SafeBuffer] link to search for the given set of facets
  def facet_link(text, facets)
    new_params = params.dup

    if facets.empty?
      new_params[:fq] = nil
      return link_to text, search_path(new_params), 'data-transition' => 'none'
    end

    new_params[:fq] = []
    facets.each { |f| new_params[:fq] << facet_to_fq(f) }
    link_to text, search_path(new_params), 'data-transition' => 'none'
  end

  # Get the list of facet links for one particular facet
  #
  # This function takes the facets from the +Document+ class, checks them
  # against +active_facets+, and creates a set of list items.  It is used
  # by +facet_link_list+.
  #
  # @param [Symbol] sym symbol for facet (e.g., +:authors_facet+)
  # @param [String] header content of list item header
  # @param [Array] active_facets array of 3-tuples for all active facets
  def list_links_for_facet(sym, header, active_facets)
    return ''.html_safe unless Document.facets

    # Get the hash of facet counts from the Document model
    hash = Hash[Document.facets[sym].sort { |a,b| -1 * (a[1] <=> b[1]) }]
    array = []

    hash.each_pair do |k, v|
      # Skip this if it's present in the active facets, or empty
      next unless active_facets.find_index([sym, k, 0]).nil?
      next if v == 0

      # Add to the array
      array << [sym, k, v]
      break if array.count == 5
    end

    # Bail if there's no facets
    ret = ''.html_safe
    return ret if array.empty?

    # Build the return value
    ret << content_tag(:li, header, 'data-role' => 'list-divider')
    array.each do |a|
      ret << content_tag(:li) do
        # Link to whatever the current facets are, plus the new one
        link = facet_link a[1], active_facets + [a]
        count = content_tag :span, a[2], :class => 'ui-li-count'
        link + count
      end
    end

    ret
  end

  # Return a set of list items for faceted browsing
  #
  # This function queries both the active facets on the current search and the
  # available facets for authors, journals, and years.  It returns a set of
  # +<li>+ elements (_not_ a +<ul>+), including list dividers.
  #
  # @return [ActiveSupport::SafeBuffer] set of list items for faceted browsing
  def facet_link_list
    # Convert the active facet parameters to 3-tuples
    active_facets = []
    params[:fq].each { |fq| active_facets << fq_to_facet(fq) } if params[:fq]

    # Start with the active facets
    ret = ''.html_safe
    unless active_facets.empty?
      ret << content_tag(:li, 'Active Filters', 'data-role' => 'list-divider')
      ret << content_tag(:li, 'data-icon' => 'delete') do
        facet_link "Remove All", []
      end
      active_facets.each do |a|
        ret << content_tag(:li, 'data-icon' => 'delete') do
          new_facets = active_facets.dup
          new_facets.delete(a)

          facet_link "#{a[0].to_s.split('_')[0].capitalize}: #{a[1]}", new_facets
        end
      end
    end

    # Run the facet-getting code for all three facet types
    ret << list_links_for_facet(:authors_facet, 'Author', active_facets)
    ret << list_links_for_facet(:journal_facet, 'Journal', active_facets)
    ret << list_links_for_facet(:year, 'Publication Date', active_facets)
    ret
  end
end
