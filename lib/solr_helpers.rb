# -*- encoding : utf-8 -*-

module SolrHelpers
  # Parse the strange format in which Solr's term vector arrays show up
  def parse_term_vectors(tvec_array)
    term_vectors = {}
    
    (0...tvec_array.length).step(2) do |i|
      term = tvec_array[i].force_encoding("UTF-8")
      attr_array = tvec_array[i+1]
      hash = {}
      
      (0...attr_array.length).step(2) do |j|
        key = attr_array[j]
        val = attr_array[j+1]
        
        case key
        when 'tf'
          hash[:tf] = Integer(val)
        when 'offsets'
          hash[:offsets] = []
          (0...val.length).step(4) do |k|
            s = Integer(val[k+1])
            e = Integer(val[k+3])
            hash[:offsets] << (s...e)
          end
        when 'positions'
          hash[:positions] = []
          (0...val.length).step(2) do |k|
            p = Integer(val[k+1])
            hash[:positions] << p
          end
        when 'df'
          hash[:df] = Float(val)
        when 'tf-idf'
          hash[:tfidf] = Float(val)
        end
      end
      
      term_vectors[term] = hash
    end
    
    term_vectors
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
    return [''.to_sym, '', 0] unless parts.count == 2

    field = parts[0]
    query = parts[1]

    # Strip quotes from the query if present
    query = query[1..-2] if query[0] == "\"" and query[query.length - 1] == "\""

    # If the field isn't 'year', we're done here
    return [field.to_sym, query, 0] unless field == 'year'

    # We need to parse the decade query if it's 'year'
    decade = query[1..-2].split[0]
    if decade == '*'
      decade = '1790'
    end
    decade = Integer(decade)

    if decade == 1790
      str = I18n.t('search.index.year_before_1800')
    elsif decade == 2010
      str = I18n.t('search.index.year_after_2010')
    else
      str = "#{decade}–#{decade + 9}"
    end

    return [field.to_sym, str, 0]
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

    # Convert the year strings
    if facet[1] == I18n.t("search.index.year_before_1800")
      query = "[* TO 1799]"
    elsif facet[1] == I18n.t("search.index.year_after_2010")
      query = "[2010 TO *]"
    else
      decade = facet[1][0, 4]
      last = Integer(decade) + 9
      query = "[#{decade} TO #{last}]"
    end

    return "year:#{query}"
  end


  # Parse the facet counts as returned by Solr into +Document.facets+
  #
  # Solr returns facets in its responses in a strange format, which we need to
  # parse into what we will store in the +Document.facets+ hash.  In particular,
  # we need to convert the year queries (stored in +facet_queries+) into usable
  # values.  To do that, we use the parsing code in +fq_to_facet+ (which creates
  # a human-readable facet name from the facet query).
  #
  # @api private
  # @return [Hash] The +Document.facets+ hash
  # @see Document.facets
  def parse_facet_counts(solr_facets)
    facets = {}
    
    # The "year" facets are handled as separate queries
    if solr_facets["facet_queries"]
      facets[:year] = {}
      solr_facets["facet_queries"].each do |k, v|
        # Use fq_to_facet to translate to a human-readable string
        f = fq_to_facet(k)
        facets[:year][f[1]] = v
      end
    end
    
    if solr_facets["facet_fields"]
      { "authors_facet" => :authors_facet, "journal_facet" => :journal_facet }.each do |s, f|
        facets[f] = Hash[*solr_facets["facet_fields"][s].flatten]
      end
    end
    
    facets
  end
end
