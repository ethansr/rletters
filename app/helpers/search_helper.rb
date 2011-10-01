# -*- encoding : utf-8 -*-

module SearchHelper
  include SolrHelpers

  # Return a formatted version of the number of documents in the last search
  # @return [String] number of documents in the last search
  def num_results_string
    if params[:precise] or params[:q] or params[:fq]
      I18n.t 'search.index.num_results_found', :count => Document.num_results
    else
      I18n.t 'search.index.num_results_database', :count => Document.num_results
    end
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
      facet_map = { :authors_facet => I18n.t('search.index.authors_facet_short'),
        :journal_facet => I18n.t('search.index.journal_facet_short'),
        :year => I18n.t('search.index.year_facet_short') }

      ret << content_tag(:li, I18n.t('search.index.active_filters'), 'data-role' => 'list-divider')
      ret << content_tag(:li, 'data-icon' => 'delete') do
        facet_link I18n.t('search.index.remove_all'), []
      end
      active_facets.each do |a|
        ret << content_tag(:li, 'data-icon' => 'delete') do
          new_facets = active_facets.dup
          new_facets.delete(a)

          facet_link "#{facet_map[a[0]]}: #{a[1]}", new_facets
        end
      end
    end

    # Run the facet-getting code for all three facet types
    ret << list_links_for_facet(:authors_facet, I18n.t('search.index.authors_facet'), active_facets)
    ret << list_links_for_facet(:journal_facet, I18n.t('search.index.journal_facet'), active_facets)
    ret << list_links_for_facet(:year, I18n.t('search.index.year_facet'), active_facets)
    ret
  end


  # Get the short, formatted representation of a document
  #
  # This function returns the short bibliographic entry for a document that will
  # appear in the search results list.
  #
  # @param [Document] doc document for which bibliographic entry is desired
  # @return [ActiveSupport::SafeBuffer] bibliographic entry for document
  def document_bibliography_entry(doc)
    render :partial => 'document', :locals => { :document => doc }
  end
end
