# -*- encoding : utf-8 -*-

# Representation of a document in the Solr database.
#
# This class provides an ActiveRecord-like model object for documents hosted in
# the RLetters Solr backend.  It abstracts both single-document retrieval and
# document searching in class-level methods, and access to the data provided by
# Solr in instance-level methods and attributes.
class Document
  # Make this class act like an ActiveRecord model, though it's not backed by
  # the database (it's in Solr)
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  # Objects of this class are not persisted in the database
  # @api private
  # @return [Boolean] false
  def persisted?; false; end
  # Objects of this class are always read-only
  # @api private
  # @return [Boolean] false
  def readonly?; true; end

  # Throw an exception if +destroy+ is called on this object
  # @api private
  # @return [undefined] always throws
  def before_destroy; raise ActiveRecord::ReadOnlyRecord; end
  # Throw an exception if +Document.delete_all+ is called
  # @api private
  # @return [undefined] always throws
  def self.delete_all; raise ActiveRecord::ReadOnlyRecord; end
  # Throw an exception if +delete+ is called on this object
  # @api private
  # @return [undefined] always throws
  def delete; raise ActiveRecord::ReadOnlyRecord; end


  # Bring in some helpers for parsing Solr's syntax
  extend SolrHelpers

  # Serialization methods
  include Serializers::BibTex
  include Serializers::CSL
  include Serializers::EndNote
  include Serializers::Marc
  include Serializers::Mods
  include Serializers::OpenURL

  # Return a document (just bibliographic data) by SHA-1 checksum
  #
  # @api public
  # @param [String] shasum SHA-1 checksum of the document to be retrieved
  # @param [Hash] options see +find_all_by_solr_query+ for specification
  # @return [Document] the document requested
  # @raise [ActiveRecord::RecordNotFound] thrown if no matching document can
  #   be found
  # @see find_all_by_solr_query
  # @example Look up the document with ID "1234567890abcdef1234"
  #   doc = Document.find("1234567890abcdef1234")
  def self.find(shasum, options = {})
    set = find_all_by_solr_query({ :q => "shasum: #{shasum}", :qt => "precise" }, options)
    raise ActiveRecord::RecordNotFound if set.empty?
    set[0]
  end

  # Return a document (bibliographic data and full text) by SHA-1 checksum
  #
  # @api public
  # @param [String] shasum SHA-1 checksum of the document to be retrieved
  # @param [Hash] options see +find_all_by_solr_query+ for specification
  # @return [Document] the document requested, including full text
  # @raise [ActiveRecord::RecordNotFound] thrown if no matching document can
  #   be found
  # @see find_all_by_solr_query
  # @example Get the full tet of the document with ID "1234567890abcdef1234"
  #   text = Document.find_with_fulltext("1234567890abcdef1234").fulltext
  def self.find_with_fulltext(shasum, options = {})
    set = find_all_by_solr_query({ :q => "shasum: #{shasum}", :qt => "fulltext" }, options)
    raise ActiveRecord::RecordNotFound if set.empty?
    set[0]
  end

  # Return the Solr response for the given query
  #
  # This function makes sure that any exceptions that may be raised by RSolr
  # are caught and handled.  This method cannot be tested, we stub it out
  # to deal with the absence of a Solr server.
  #
  # @api private
  # @param [Hash] params Solr query parameters
  # @return [Hash] Solr search result
  #:nocov:
  def self.get_solr_response(query)
    begin
      solr = RSolr.connect :url => APP_CONFIG['solr_server_url']
      ret = solr.get('select', :params => query)
    rescue Exception
      ret = {}
    end

    ret
  end
  #:nocov:

  # Find a set of documents using a direct Solr query
  #
  # With the exception of processing the +:offset+ and +:limit+ options, 
  # the +params+ array will be passed directly to Solr.
  #
  # @api public
  # @param [Hash] params Solr query parameters
  #   This is a hash that can have (at least) the following keys:
  #   - +params[:q]+: a Solr query string, typically of the format "field:val 
  #     field:val ..."
  #   - +params[:qt]+: the Solr query type.  In the default Solr configuration
  #     provided with RLetters, valid values here are +standard+ (for stemmed,
  #     Google-like searching), +precise+ (full Solr query syntax, returning
  #     bibliographic data only), and +fulltext (full Solr query syntax,
  #     returning both bibliographic data and full document text).
  #   - +params[:start]+: alternate way to set +options[:offset]+.
  #   - +params[:rows]+: alternate way to set +options[:limit]+.
  # @param [Hash] options subset of the options usually passed to
  #   +ActiveRecord::find+
  # @option options [Integer] offset offset within the result set at which to
  #   begin returning documents
  # @option options [Integer] limit maximum number of results to return
  # @return [Array] set of documents matching query.  An empty set will be
  #   returned if no documents match.
  #
  # @example Return all documents in the collection (bad idea!)
  #  collection = Document.find_all_by_solr_query({ :q => "*:*", :qt => "precise" })
  # @example Return all documents which (fuzzily) match "general"
  #  results = Document.find_all_by_solr_query({ :q => "general", :qt => "standard" })
  # @example Return all documents published in 1983
  #  results = Document.find_all_by_solr_query({ :q => "year:1983", :qt => "precise" })
  def self.find_all_by_solr_query(params, options = {})
    # Map from common Rails options to Solr options
    params[:start] = options[:offset] if options[:offset]
    params[:rows] = options[:limit] if options[:limit]

    # Do the Solr query
    solr_response = get_solr_response(params)

    # Set the num_results count (before possibly bailing!)
    @@num_results = 0
    if solr_response["response"] && solr_response["response"]["numFound"]
      @@num_results = Integer(solr_response["response"]["numFound"])
    end

    raise ActiveRecord::StatementInvalid unless solr_response["response"]
    raise ActiveRecord::StatementInvalid unless solr_response["response"]["numFound"]
    return [] if solr_response["response"]["numFound"] == 0
    raise ActiveRecord::StatementInvalid unless solr_response["response"]["docs"]
    
    # Grab all of the document-attributes that Solr returned, forcing
    # everything into UTF-8 encoding, which is how all Solr's data
    # comes back
    documents = solr_response["response"]["docs"]
    documents.map! do |doc| 
      doc.each do |k, v|
        if v.is_a? String
          doc[k] = v.force_encoding("UTF-8")
        end
      end
    end

    # See if the term vectors are available, and add them to the documents
    if solr_response["termVectors"]
      (0...solr_response["termVectors"].length).step(2) do |i|
        doc_shasum = solr_response["termVectors"][i + 1][1]
        doc_tvec_array = solr_response["termVectors"][i + 1][3]
        
        idx = documents.find_index { |doc| doc['shasum'] == doc_shasum }
        unless idx.nil?
          documents[idx]["term_vectors"] = parse_term_vectors(doc_tvec_array)
        end
      end
    end

    # See if the facets are available, and set the class variable if so
    @@facets = nil
    if solr_response["facet_counts"]
      @@facets = parse_facet_counts(solr_response["facet_counts"])
    end

    # Initialize all the documents and get out of here
    documents.map { |attrs| Document.new(attrs) }
  end

  # @return [String] the SHA-1 checksum of this document
  attr_reader :shasum
  # @return [String] the DOI (Digital Object Identifier) of this document
  attr_reader :doi
  # @return [String] the document's authors, in a comma-delimited list
  attr_reader :authors
  # @return [Array] the document's authors, in an array
  attr_reader :author_list
  # @return [Array] the document's authors, split into name parts, in an array
  # @see NameHelpers.author_name_parts
  attr_reader :formatted_author_list
  # @return [String] the title of this document
  attr_reader :title
  # @return [String] the journal in which this document was published
  attr_reader :journal
  # @return [String] the year in which this document was published
  attr_reader :year
  # @return [String] the journal volume number in which this document was 
  #   published
  attr_reader :volume
  # @return [String] the journal issue number in which this document was
  #   published
  attr_reader :number
  # @return [String] the page numbers in the journal of this document, in the
  #   format "start-end"
  attr_reader :pages
  # @return [String] the full text of this document.  May be +nil+ if the query
  #   type used to retrieve the document does not provide the full text
  attr_reader :fulltext
  
  # @return [String] the starting page of this document, if it can be parsed
  def start_page
    return '' if pages.blank?
    pages.split('-')[0]
  end
  
  # @return [String] the ending page of this document, if it can be parsed
  def end_page
    return '' if pages.blank?
    parts = pages.split('-')
    return '' if parts.length <= 1
    
    spage = parts[0]
    epage = parts[-1]
    
    # Check for range strings like "1442-7"
    if spage.length > epage.length
      ret = spage
      ret[-epage.length..-1] = epage
    else
      ret = epage
    end
    ret
  end
  
  # Term vectors for this document
  #
  # The Solr server returns a list of information for each term in every 
  # document.  The following data is provided (based on Solr server 
  # configuration):
  #
  # - +:tf+, term frequency: the number of times this term appears in
  #   the given document
  # - +:offsets+, term offsets: the start and end character offsets for
  #   this word within +fulltext+.  Note that these offsets can be
  #   complicated by string encoding issues, be careful when using them!
  # - +:positions+, term positions: the position of this word (in
  #   _number of words_) within +fulltext+.  Note that these positions
  #   rely on the precise way in which Solr splits words, which is specified
  #   by Unicode UAX 29.
  # - +:df+, document frequency: the number of documents in the collection
  #   that contain this word
  # - +:tfidf+, term frequency-inverse document frequency: equal to (term
  #   frequency / number of words in this document) * log(size of collection
  #   / document frequency).  A measure of how "significant" or "important"
  #   a given word is within a document, which gives high weight to words
  #   that occur frequently in a given document but do _not_ occur in other
  #   documents.
  #
  # @note This function may return +nil+, if the query type requested from
  #   the Solr server does not return term vectors.
  #
  # @api public
  # @return [Hash] term vector information.  The hash contains the following
  #   keys:
  #     term_vectors["word"]
  #     term_vectors["word"][:tf] = Integer
  #     term_vectors["word"][:offsets] = Array
  #     term_vectors["word"][:offsets][0] = Range
  #     # ...
  #     term_vectors["word"][:positions] = Array
  #     term_vectors["word"][:positions][0] = Integer
  #     # ...
  #     term_vectors["word"][:df] = Float
  #     term_vectors["word"][:tfidf] = Float
  #     term_vectors["otherword"]
  #     # ...
  # @example Get the frequency of the term "general" in this document
  #   doc.term_vectors["general"][:tf]
  attr_reader :term_vectors

  # Faceted browsing information that was returned by the last search
  #
  # For the purposes of faceted browsing, the Solr server (as configured by 
  # default in RLetters) returns the number of items within the current search 
  # with each author, journal, or publication decade.
  #
  # @api public
  # @return [Hash] facets returned by the last search, +nil+ if none.
  #   The hash contains the following keys:
  #     Document.facets[:author]["Particular Author"] = Integer
  #     Document.facets[:journal]["Particular Journal"] = Integer
  #     Document.facets[:year]["1980"] = Integer
  #   The +:year+ facet is handled specially: the value for "1980" is the
  #   facet count for the entire decade 1980-1989.
  #
  # @example Get the number of documents in the last search published by W. Shatner
  #   shatner_docs = Document.facets[:author]["W. Shatner"]
  cattr_reader :facets

  # Number of documents returned by the last search
  #
  # Since the search results (i.e., the size of the +@documents+ variable 
  # for a given view) are almost always limited by the per-page count,
  # this variable returns the full number of documents that were returned by
  # the last search.
  #
  # A method for pretty-printing this variable is available as
  # +SearchHelper#num_results_string+.
  #
  # @api public
  # @return [Integer] number of documents in the last search
  # @example Returns true if there are more hits than documents returned
  #   @documents.count > Document.num_results
  # @see SearchHelper#num_results_string
  cattr_reader :num_results

  # The shasum attribute is the only required one
  validates :shasum, :presence => true
  validates :shasum, :length => { :is => 20 }
  validates :shasum, :format => { :with => /\A[a-fA-F\d]+\z/ }

  def initialize(attributes = {})
    attributes.each do |name, value|
      instance_variable_set("@#{name}".to_sym, value)
    end

    # Split out the author list and format it
    @author_list = @authors.split(',').map { |a| a.strip } unless @authors.nil?
    @formatted_author_list = @author_list.map { |a| NameHelpers.name_parts(a) } unless @author_list.nil?
  end
end
