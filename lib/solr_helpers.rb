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

  # Parse the facet counts as returned by Solr into a hash.
  def parse_facet_counts(solr_facets)
    facets = {}
    
    # The "year" facets are handled as separate queries
    if solr_facets["facet_queries"]
      facets[:year] = {}
      solr_facets["facet_queries"].each do |k, v|
        decade = k.slice(6..-1).split[0]
        decade = "1790" if decade == "*"
        facets[:year][decade] = v
      end
    end
    
    if solr_facets["facet_fields"]
      { "authors_facet" => :author, "journal_facet" => :journal }.each do |s, f|
        facets[f] = Hash[*solr_facets["facet_fields"][s].flatten]
      end
    end
    
    facets
  end
end
