require 'active_record'

class Document  
  attr_reader :shasum, :doi, :authors, :title, :journal
  attr_reader :year, :volume, :number, :pages, :fulltext
  attr_reader :term_vectors, :term_list
  
  def doi_url
    "http://dx.doi.org/" + doi
  end
  
  
  
  def self.all
    search("*:*", true)
  end
  
  # Look up an individual document with the given shasum.  If the fulltext
  # parameter is set to true, we will retrieve it, otherwise we will not.
  #
  # If a matching document cannot be found, then this function will raise a 
  # RecordNotFound exception.  Other, worse exceptions may be thrown out of
  # RSolr.
  def self.find(shasum, fulltext = false)
    solr = connect_to_solr
    
    # This is the only method here that can fail -- if we get no response,
    # a bad response, or something that cannot be evaluated, then we have
    # trouble.  But we'll just let that exception percolate up and cause a
    # 500 error.
    query_type = fulltext ? "fulltext" : "precise"
    solr_response = solr.get('select', :params => { :qt => query_type, :q => "shasum:#{shasum}" })
    
    # See if we have a document.  We only need to check == 0, because Solr
    # has the 'shasum' field set as a unique key.  (Non-symbolized string hash
    # keys?)
    raise ActiveRecord::RecordNotFound unless solr_response.has_key? "response"
    raise ActiveRecord::RecordNotFound unless solr_response["response"].has_key? "numFound"
    raise ActiveRecord::RecordNotFound if solr_response["response"]["numFound"] == 0
    raise ActiveRecord::RecordNotFound unless solr_response["response"].has_key? "docs"
    
    # Get term vectors, if we're full-text
    term_vectors = term_list = nil
    if fulltext and solr_response.has_key? "termVectors"
      # The response format here is incredibly arcane and nearly useless,
      # turn it into something worthwhile
      tvec_array = solr_response["termVectors"][1][3]
      term_vectors = {}
      
      1.step(tvec_array.length, 2) do |i|
        term = tvec_array[i-1]
        attr_array = tvec_array[i]
        hash = {}
        
        1.step(attr_array.length, 2) do |j|
          key = attr_array[j-1]
          val = attr_array[j]
          
          case key
          when 'tf'
            hash[:tf] = Integer(val)
          when 'offsets'
            hash[:offsets] = []
            3.step(val.length, 4) do |k|
              s = Integer(val[k-2])
              e = Integer(val[k])
              hash[:offsets] << Range.new(s,e)
            end
          when 'positions'
            hash[:positions] = []
            1.step(val.length, 2) do |k|
              p = Integer(val[k])
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
    end
    
    Document.new(solr_response["response"]["docs"][0], term_vectors)
  end
  
  # Look up an array of documents with the passed Solr query string (in the
  # appropriate format for the Solr 'q' parameter).  If 'precise' is 
  # specified, then the query parameter should be in Solr's Lucene syntax.
  # Otherwise, it's a dismax search, our version of Google.
  #
  # This returns an empty array on failure, and will not throw except in 
  # dire circumstances.
  def self.search(query, precise = false)
    solr = connect_to_solr
    
    query_params = { :q => query }
    if precise
      query_params[:qt] = "precise"
    end
    
    # See the note on solr.get in self.find
    solr_response = solr.get('select', :params => query_params)
    if not solr_response.has_key? "response" or not solr_response["response"].has_key? "docs"
      return []
    end
    
    solr_response["response"]["docs"].collect { |doc| Document.new doc }
  end
  
  # Initialize a new document from the provided Solr document result.
  #
  #   doc = Document.new(solr_response["response"]["docs"][0])
  #
  # If you want the document to contain term vectors, you
  # can pass those in, otherwise they will be nil by default.
  def initialize(solr_doc, term_vectors = nil)
    %W(shasum doi authors title journal year volume number pages fulltext).each do |k|
      if solr_doc.has_key? k
        self.instance_variable_set("@#{k}", solr_doc[k])
      else
        self.instance_variable_set("@#{k}", "")
      end
    end
    
    @term_vectors = term_vectors
  end
  
  # Return the document's SHA-1 sum, which will function as a URL parameter.
  # It's pre-sanitized for our convenience, all characters can appear in
  # URLs.
  def to_param
    shasum
  end  
  
  
  # Solr connection parameters
  @@SOLR_URL = "http://localhost:8080/solr"
  
  # Get a connection to Solr using RSolr.  At least on current versions of
  # RSolr (1.0.0), this method actually can't fail, as RSolr only connects
  # when a query method is called.
  def self.connect_to_solr()
    RSolr.connect :url => @@SOLR_URL
  end
  private_class_method :connect_to_solr



  # Glue for making us act like an ActiveModel object
  extend ActiveModel::Naming
  
  def to_model
    self
  end
  
  def valid?()      true end
  def new_record?() true end
  def destroyed?()  true end
  
  def errors
    obj = Object.new
    def obj.[](key) [] end
    def obj.full_messages() [] end
    obj
  end
end

