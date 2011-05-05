# coding: UTF-8

require 'active_record'

class Document
  # The SHA-1 hash of the document's PDF file
  attr_reader :shasum
  
  # The DOI (Digital Object Identifier) of this document
  attr_reader :doi
  
  # A URL to the DOI-resolving page for the document
  def doi_url; "http://dx.doi.org/" + doi; end
  
  # The document's authors, in "First Last" format, separated
  # by commas
  attr_reader :authors
  
  # A list of document authors, for iteration
  def author_list; authors.split(",").map!{ |a| a.strip! || a }; end
  
  # The title of the document
  attr_reader :title
  
  # The journal in which the document was published
  attr_reader :journal
  
  # The year in which the document was published
  attr_reader :year
  
  # The volume of the journal in which the article appears
  attr_reader :volume
  
  # The issue number of the journal in which the article appears
  attr_reader :number
  
  # Page numbers of the article
  attr_reader :pages
  
  # Starting page of the article
  def start_page
    return '' if pages.blank?
    pages.split('-')[0]
  end
  
  # Ending page of the article, if present
  def end_page
    return '' if pages.blank?
    parts = pages.split('-')
    if parts.length > 1
      parts[-1]
    else
      ''
    end
  end
  
  # OCR'ed full text of the document.  Available only if the document
  # is retrieved by +Document.find+ with the +fulltext+ parameter set
  # to +true+.
  attr_reader :fulltext
  
  # Term vectors for this document.  This is provided in the following
  # format:
  #
  #   doc.term_vectors["word"]
  #     # Term frequency (number of times this term appears in doc)
  #     doc.term_vectors["word"][:tf] = Integer
  #     # Term offsets
  #     doc.term_vectors["word"][:offsets] = Array
  #       # The start and end character offsets for "word" within 
  #       # doc.fulltext
  #       doc.term_vectors["word"][:offsets][0] = Range
  #       ...
  #     # Term positions
  #     doc.term_vectors["word"][:positions] = Array
  #       # The word-index of this word in doc.fulltext
  #       doc.term_vectors["word"][:positions][0] = Integer
  #       ...
  #     # Number of documents in collection that contain "word"
  #     doc.term_vectors["word"][:df] = Float
  #     # Term frequency-inverse document frequency for "word"
  #     doc.term_vectors["word"][:tfidf] = Float
  #   doc.term_vectors["otherword"]
  #   ...
  #
  attr_reader :term_vectors  
  
  # Highlighting snippets for this document.  An array of strings.
  attr_reader :snippets

  # The URL parameters for an OpenURL query
  def openurl_query
    params = "ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article"
    params << "&rft_id=info:doi%2F#{CGI::escape(doi)}" unless doi.blank?
    params << "&rft.atitle=#{CGI::escape(title)}"
    params << "&rft.title=#{CGI::escape(journal)}"
    params << "&rft.date=#{CGI::escape(year)}" unless year.blank?
    params << "&rft.volume=#{CGI::escape(volume)}" unless volume.blank?
    params << "&rft.issue=#{CGI::escape(number)}" unless number.blank?
    params << "&rft.spage=#{CGI::escape(start_page)}" unless start_page.blank?
    params << "&rft.epage=#{CGI::escape(end_page)}" unless end_page.blank?
    parts = Document.author_name_parts(author_list[0])
    params << "&rft.aufirst=#{CGI::escape(parts[:first])}"
    params << "&rft.aulast=#{CGI::escape(parts[:last])}"
    author_list[1...author_list.size].each do |a|
      params << "&rft.au=#{CGI::escape(a)}"
    end
    params
  end
  
  # Get a MARC record for this document
  def marc_record
    record = MARC::Record.new()
    
    record.append(MARC::ControlField.new('001', shasum))
    record.append(MARC::ControlField.new('003', "PDFSHASUM"))
    record.append(MARC::ControlField.new('005', Time.now.strftime("%Y%m%d%H%M%S.0")))
    record.append(MARC::ControlField.new('008', "110501s#{sprintf '%04d', year}#######||||fo#####||0#0|eng#d"))
    record.append(MARC::DataField.new('040', '#', '#',
      ['a', 'evoText'], ['b', 'eng'], ['c', 'evoText']))
    
    record.append(MARC::DataField.new('024', '7', '#',
      ['2', 'doi'], ['a', doi]))
    
    parts = Document.author_name_parts(author_list[0])
    first_author = ''
    first_author << parts[:von] + ' ' unless parts[:von].blank?
    first_author << parts[:last]
    first_author << ' ' + parts[:suffix] unless parts[:suffix].blank?
    first_author << ', ' + parts[:first]
    record.append(MARC::DataField.new('100', '1', '#',
      MARC::Subfield.new('a', first_author)))
    
    author_list.each do |a|
      parts = Document.author_name_parts(a)
      author = ''
      author << parts[:von] + ' ' unless parts[:von].blank?
      author << parts[:last]
      author << ' ' + parts[:suffix] unless parts[:suffix].blank?
      author << ', ' + parts[:first]
      record.append(MARC::DataField.new('700', '1', '#',
        MARC::Subfield.new('a', author)))
    end
    
    marc_title = title
    marc_title << '.' unless title[-1] == '.'
    record.append(MARC::DataField.new('245', '1', '0',
      ['a', marc_title]))
    
    marc_volume = ''
    marc_volume << "v. #{volume}" unless volume.blank?
    marc_volume << " " unless volume.blank? or pages.blank?
    marc_volume << "no. #{number}" unless number.blank?
    record.append(MARC::DataField.new('490', '1', '#',
      MARC::Subfield.new('a', journal),
      MARC::Subfield.new('v', marc_volume)))
    record.append(MARC::DataField.new('830', '#', '0',
      MARC::Subfield.new('a', journal),
      MARC::Subfield.new('v', marc_volume)))
    
    marc_free = ''
    unless volume.blank?
      marc_free << "Vol. #{volume}"
      marc_free << (number.blank? ? " " : ", ")
    end
    marc_free << "no. #{number} " unless number.blank?
    marc_free << "(#{year})"
    marc_free << ", p. #{pages}" unless pages.blank?
    
    marc_enumeration = ''
    marc_enumeration << volume unless volume.blank?
    marc_enumeration << ":#{number}" unless number.blank?
    marc_enumeration << "<#{start_page}" unless start_page.blank?
    record.append(MARC::DataField.new('773', '0', '#',
      ['t', journal], ['g', marc_free], ['q', marc_enumeration], ['7', 'nnas']))
    
    subfields = []
    subfields << ['a', volume] unless volume.blank?
    subfields << ['b', number] unless number.blank?
    subfields << ['c', start_page] unless start_page.blank?
    subfields << ['i', year]
    record.append(MARC::DataField.new('363', '#', '#', *subfields))
    
    record.append(MARC::DataField.new('362', '0', '#', ['a', year + '.']))
    
    record
  end
  
  # Output in MODS XML format
  def mods_document
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.mods("xmlns:xlink" => "http://www.w3.org/1999/xlink",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xmlns" => "http://www.loc.gov/mods/v3", "version" => "3.0",
      "xsi:schemaLocation" => "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd") do |mods|
      mods.titleInfo do |ti|
        ti.title title
      end
      author_list.each do |a|
        parts = Document.author_name_parts(a)
        mods.name(:type => 'personal') do |name|
          name.namePart(parts[:first], :type => 'given')
          last_name = ''
          last_name << " #{parts[:von]}" unless parts[:von].blank?
          last_name << parts[:last]
          last_name << ", #{parts[:suffix]}" unless parts[:suffix].blank?
          name.namePart(last_name, :type => 'family')
          name.role do |role|
            role.roleTerm('author', :type => 'text')
          end
        end
      end
      mods.typeOfResource 'text'
      mods.genre 'article'
      mods.originInfo do |oi|
        oi.issuance 'monographic'
      end
      mods.relatedItem(:type => 'host') do |ri|
        ri.titleInfo do |ti|
          ti.title journal
        end
        ri.originInfo do |oi|
          oi.issuance 'continuing'
        end
        ri.part do |part|
          unless volume.blank?
            part.detail(:type => 'volume') do |d|
              d.number volume
            end
          end
          unless number.blank?
            part.detail(:type => 'issue') do |d|
              d.number number
              d.caption 'no.'
            end
          end
          unless pages.blank?
            part.extent(:unit => 'pages') do |e|
              e.start start_page unless start_page.blank?
              e.end end_page unless end_page.blank?
            end
          end
          part.date year
        end
      end
      mods.identifier(doi, :type => 'doi')
      mods.target!
    end
  end
    
  
  # Look up an individual document with the given shasum.  If the fulltext
  # parameter is set to true, +document.fulltext+ and +document.term_vectors+
  # will be set.
  #
  # If hl_word is set to true (must be set in combination with fulltext), then
  # enable highlighting and return a document with +document.snippets+ set
  # for the appropriate word.
  #
  # If a matching document cannot be found, then this function will raise a 
  # RecordNotFound exception.  Other, worse exceptions may be thrown out of
  # RSolr.
  #
  # This function returns a hash:
  #
  #   h = Document.find("1234567890abcdef", true)
  #   h[:document] = Document
  #   h[:query_time] = Float
  #
  def self.find(shasum, fulltext = false, hl_word = nil)
    solr = RSolr.connect :url => APP_CONFIG['solr_server_url']
    
    # This is the only method here that can fail -- if we get no response,
    # a bad response, or something that cannot be evaluated, then we have
    # trouble.  But we'll just let that exception percolate up and cause a
    # 500 error.
    query_params = {}
    query_params[:q] = "shasum:#{shasum}"
    query_params[:qt] = fulltext ? "fulltext" : "precise"
    if fulltext and hl_word
      query_params[:q] += " fulltext:#{hl_word}"
      query_params[:hl] = "on"
    end
    solr_response = solr.get('select', :params => query_params)
    
    raise ActiveRecord::RecordNotFound unless solr_response["response"]
    raise ActiveRecord::RecordNotFound unless solr_response["response"]["numFound"]
    raise ActiveRecord::RecordNotFound if solr_response["response"]["numFound"] == 0
    raise ActiveRecord::RecordNotFound unless solr_response["response"]["docs"]
    
    # Get term vectors, if we're full-text
    term_vectors = nil
    if fulltext and solr_response["termVectors"]
      # The response format here is incredibly arcane and nearly useless,
      # turn it into something worthwhile
      tvec_array = solr_response["termVectors"][1][3]
      term_vectors = {}
      
      (0...tvec_array.length).step(2) do |i|
        term = tvec_array[i]
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
    end
    
    snippets = nil
    if fulltext and solr_response["highlighting"]
      snippets = solr_response["highlighting"][shasum]["fulltext"]
    end
    
    { :document => Document.new(solr_response["response"]["docs"][0], term_vectors, snippets),
      :query_time => Float(solr_response["responseHeader"]["QTime"]) / 1000.0 }
  end
  
  # Look up an array of documents from the given parameters structure.
  # Recognized here are the following:
  #
  #   # Solr query string
  #   :q => String
  #   # Solr faceted query (an array)
  #   :fq[] => Array[String]
  #   # If present, send query through Solr syntax, else the Dismax parser
  #   :precise => Nil?
  #   # Search query for authors
  #   :authors => String
  #   # Search query for title
  #   :title => String
  #   # Perform an exact or a stemmed title search?
  #   :title_type => String (exact|fuzzy)
  #   # Search query for journal
  #   :journal => String
  #   # Perform an exact or a stemmed journal search?
  #   :journal_type => String (exact|fuzzy)
  #   # Start year for year range
  #   :year_start => String
  #   # End year for year range
  #   :year_end => String
  #   # Search query for volume
  #   :volume => String
  #   # Search query for number
  #   :number => String
  #   # Search query for pages
  #   :pages => String
  #   # Search query for fulltext
  #   :fulltext => String
  #   # Perform an exact or a stemmed fulltext search?
  #   :fulltext_type => String (exact|fuzzy)
  #
  # This function returns a hash:
  #
  #   h = Document.find("1234567890abcdef", true)
  #   h[:documents] = Array[Document]
  #   h[:query_time] = Float
  #   h[:facets] = Hash
  #     h[:facets][:author]
  #     h[:facets][:journal]
  #     h[:facets][:year]
  #       h[:facets][...]["Facet Element"] = Integer
  #
  # On failure, this will simply return an empty +:documents+ array, and
  # will not throw an exception unless an RSolr error occurs.
  def self.search(params)
    solr = RSolr.connect :url => APP_CONFIG['solr_server_url']
    
    params.delete_if { |k, v| v.blank? }
    query_params = { :fq => params[:fq] }
    
    if params.has_key? :precise
      query_params[:qt] = "precise"
      query_params[:q] = "#{params[:q]} "
      
      %W(authors volume number pages).each do |f|
        query_params[:q] += " #{f}:(#{params[f.to_sym]})" if params[f.to_sym]
      end
      
      %W(title journal fulltext).each do |f|
        field = f
        field += "_search" if params[(f + "_type").to_sym] and params[(f + "_type").to_sym] == "fuzzy"
        query_params[:q] += " #{field}:(#{params[f.to_sym]})" if params[f.to_sym]
      end
      
      # Year has to be handled separately for range support
      if params[:year_start] or params[:year_end]
        year = params[:year_start]
        year ||= params[:year_end]
        if params[:year_start] and params[:year_end]
          year = "[#{params[:year_start]} TO #{params[:year_end]}]"
        end
        
        query_params[:q] += " year:(#{year})"
      end
      
      # If there's still no query, return all documents
      query_params[:q].strip!
      if query_params[:q].empty?
        query_params[:q] = "*:*"
      end
    else
      if not params.has_key? :q
        query_params[:q] = "*:*"
        query_params[:qt] = "precise"
      else
        query_params[:q] = params[:q]
      end
    end
    
    # See the note on solr.get in self.find
    solr_response = solr.get('select', :params => query_params)
    unless solr_response["response"] and solr_response["response"]["docs"]
      return { :documents => [], :query_time => 0, :facets => nil }
    end
    
    # Process the facet information
    facets = nil
    if solr_response["facet_counts"]
      facets = {}
      solr_facets = solr_response["facet_counts"]
      
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
    end
    
    { :documents => solr_response["response"]["docs"].collect { |doc| Document.new doc },
      :query_time => Float(solr_response["responseHeader"]["QTime"]) / 1000.0,
      :facets => facets }
  end
  
  # Initialize a new document from the provided Solr document result.
  #
  #   doc = Document.new(solr_response["response"]["docs"][0])
  #
  # If you want the document to contain term vectors or snippets, you
  # can pass those in, otherwise they will be nil by default.
  def initialize(solr_doc, term_vectors = nil, snippets = nil)
    %W(shasum doi authors title journal year volume number pages fulltext).each do |k|
      if solr_doc[k]
        instance_variable_set("@#{k}", solr_doc[k].force_encoding("UTF-8"))
      else
        instance_variable_set("@#{k}", "".force_encoding("UTF-8"))
      end
    end
    
    @term_vectors = term_vectors
    @snippets = snippets
  end
  
  # Return the document's SHA-1 sum, which will function as the permanent
  # URL parameter for a document.
  def to_param
    shasum
  end  
  
  
  
  def self.author_name_parts(a)
    au = a.dup
    first = ''
    last = ''
    von = ''
    suffix = ''
    
    # Check for a BibTeX "von-part"
    if m = au.match(/( |^)(von der|von|van der|van|del|de la|de|St|don|dos) /)
      von = m[2]
      s = m.begin(2)
      e = m.end(2)
      
      # Special case: if the von part starts the string, then it'd better be
      # comma-separated later (erase it and we'll fall through)
      if s == 0
        au[s...e] = ''
      else
        # Otherwise, this constitutes our splitter
        first = au[0...s]
        last = au[e...au.length]
        au = ''
      end
    end
    
    # Check for a BibTeX "suffix-part"
    if m = au.match(/(,? ((Jr|Sr|1st|2nd|3rd|IV|III|II|I)\.?))/)
      suffix = m[2]
      s = m.begin(1)
      e = m.end(1)
      
      # If it's not at the end of the string, then it's a splitter, though
      # make sure to check for a comma
      if e != au.length
        before = au[0...s]
        after = au[e...au.length]
        
        if after[0] == ','
          after[0] = ''
        end
        
        last = before
        first = after
        au = ''
      else
        # Okay, we've got it, just erase it
        au[s...e] = ''
      end
    end
    
    # Now we should have only first and last names, possibly separated by
    # a comma.  If au is empty, though, we've already parsed them out.
    unless au.blank?
      # Look for a comma, that's the easy method
      if m = au.match(/(,)/)
        if m.begin(1) == 0
          # Broken string that begins w/ a comma?
          first = au[1, -1]
          last = ''
        else
          last = au[0...m.begin(1)]
          first = au[m.end(1)...au.length]
        end
      else
        # No comma, take the last single name as the last name
        parts = au.split(' ')
        if parts.length == 1
          last = au
          first = ''
        else
          last = parts[-1]
          first = parts[0...parts.length - 1].join(' ')
        end
      end
    end
    
    # Trim everything
    first.strip!
    last.strip!
    von.strip!
    suffix.strip!

    { :first => first, :last => last, :von => von, :suffix => suffix }
  end
  
  

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

