class Document
  # Make this class act like an ActiveRecord model, though it's
  # not backed by the database (it's in Solr)
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  def persisted?; false; end
  def readonly?; true; end

  def before_destroy; raise ActiveRecord::ReadOnlyRecord; end
  def self.delete_all; raise ActiveRecord::ReadOnlyRecord; end
  def delete; raise ActiveRecord::ReadOnlyRecord; end

  # Bring in some helpers for parsing Solr's syntax
  extend SolrHelpers

  # How to act appropriately ActiveModel-y:
  # - To do serialization, integrate it into the ActiveModel::Serializers
  # so it acts right.

  # Return a single document (just bibliographic data) by SHA-1 checksum.
  # The return value and options are documented in find_all_by_solr_query.
  def self.find(shasum, options = {})
    set = find_all_by_solr_query({ :q => "shasum: #{shasum}", :qt => "precise" }, options)
    throw ActiveRecord::RecordNotFound if set.empty?
    set[0]
  end

  # Return a single document (bibliographic data and full text) by
  # SHA-1 checksum.  The return value and options are documented in 
  # find_all_by_solr_query.
  def self.find_with_fulltext(shasum, options = {})
    set = find_all_by_solr_query({ :q => "shasum: #{shasum}", :qt => "fulltext" }, options)
    throw ActiveRecord::RecordNotFound if set.empty?
    set[0]
  end

  # Find a set of documents using a direct Solr query.  +params+ is an
  # array that will be passed directly to Solr.  It can have (at least)
  # the following keys:
  #
  #  - +params[:q]+ is a Solr query string "field:val field:val ..."
  #  - +params[:qt]+ is the Solr query type.  The default query language
  #    includes the types +standard+ (for stemmed, Google-like searching),
  #    +precise+ (bibliographic data only), and +fulltext+ (bibliographic
  #    data plus full document text)
  #
  # You can return a limited set of results either by setting +params[:start]+
  # and +params[:rows]+, or by using the standard Rails options +:offset:+
  # and +:limit+ as usually passed to <tt>ActiveRecord::find</tt>.
  def self.find_all_by_solr_query(params, options = {})
    # Map from common Rails options to Solr options
    params[:start] = options[:offset] if options[:offset]
    params[:rows] = options[:limit] if options[:limit]

    # Connect to Solr and execute the query
    solr = RSolr.connect :url => APP_CONFIG['solr_server_url']
    solr_response = solr.get('select', :params => params)
    
    throw ActiveRecord::StatementInvalid unless solr_response["response"]
    throw ActiveRecord::StatementInvalid unless solr_response["response"]["numFound"]
    return [] if solr_response["response"]["numFound"] == 0
    throw ActiveRecord::StatementInvalid unless solr_response["response"]["docs"]
    
    # Grab all of the document-attributes that Solr returned, forcing
    # everything into UTF-8 encoding, which is how all Solr's data
    # comes back
    documents = solr_response["response"]["docs"]
    documents.map! { |doc| doc.each { |k, v| doc[k] = v.force_encoding("UTF-8") }}

    # See if the term vectors are available, and add them to the documents
    if solr_response["termVectors"]
      (0...solr_response["termVectors"].length).step(2) do |i|
        doc_shasum = solr_response["termVectors"][i + 1][1]
        doc_tvec_array = solr_response["termVectors"][i + 1][3]
        
        idx = documents.find_index { |doc| doc.shasum == doc_shasum }
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

  # These are all the attributes that come directly out of the
  # Solr schema
  attr_reader :shasum, :doi, :authors, :title, :journal, :year,
              :volume, :number, :pages, :fulltext
  
  # Term vectors for this document.  This is provided in the following
  # format:
  #
  # doc.term_vectors["word"]
  # # Term frequency (number of times this term appears in doc)
  # doc.term_vectors["word"][:tf] = Integer
  # # Term offsets
  # doc.term_vectors["word"][:offsets] = Array
  # # The start and end character offsets for "word" within
  # # doc.fulltext
  # doc.term_vectors["word"][:offsets][0] = Range
  # ...
  # # Term positions
  # doc.term_vectors["word"][:positions] = Array
  # # The word-index of this word in doc.fulltext
  # doc.term_vectors["word"][:positions][0] = Integer
  # ...
  # # Number of documents in collection that contain "word"
  # doc.term_vectors["word"][:df] = Float
  # # Term frequency-inverse document frequency for "word"
  # doc.term_vectors["word"][:tfidf] = Float
  # doc.term_vectors["otherword"]
  # ...
  #
  attr_reader :term_vectors

  # Facets that were returned by the last search.  These are provided in
  # the following format (year facets are by decade, from XXX0-XXX9):
  #
  #   Document.facets = Hash
  #     Document.facets[:author]["Particular Author"] = Integer
  #     Document.facets[:journal]["Particular Journal"] = Integer
  #     Document.facets[:year]["1980"] = Integer
  #
  # If the last search did not return any facet data, +facets+ will be +nil+.
  @@facets = nil
  def self.facets; @@facets; end

  # The shasum attribute is the only required one
  validates :shasum, :presence => true
  validates :shasum, :length => { :is => 20 }
  validates :shasum, :format => { :with => /\A[a-fA-F\d]+\z/, :message => "Invalid SHA1 checksum" }

  def initialize(attributes = {})
    attributes.each do |name, value|
      instance_variable_set("@#{name}".to_sym, value)
    end
  end

end
