# -*- encoding : utf-8 -*-

# Code for formatting the names of authors
module NameHelpers
  
  # Split a name into its component parts
  #
  # This function applies the standard BibTeX author name splitting rules
  # to the given name.  These parsing functions aren't bulletproof, but I've
  # tried to duplicate the BibTeX parsing as much as I can, which is something
  # of an industry standard.
  #
  # @api public
  # @param [String] a the name to split
  # @return [Hash] parts of the author's name
  #   +ret[:first]+: first name
  #   +ret[:last]+: last name
  #   +ret[:von]+: "von" part, such as "van der"
  #   +ret[:suffix]+: suffix, such as "Sr."
  # @example Split a complicated name into its parts
  #   NameHelpers.name_parts("First van der Last, Jr")
  #   # { :first => "First", :von => "van der", :last => "Last", :suffix => "Jr" }
  def self.name_parts(a)
    au = a.dup
    first = ''
    last = ''
    von = ''
    suffix = ''
    
    # Check for a BibTeX "von-part"
    if m = au.match(/( |^)(von der|von|van der|van|del|de la|de|St|don|dos) /u)
      von = m[2]
      s = m.begin(2)
      e = m.end(2)
      
      # Special case: if the von part starts the string, then it'd better be
      # comma-separated later (erase it and we'll fall through)
      if s == 0
        au[s...e] = ''
        unless au.include? ","
          last = au
          au = ''
        end
      else
        # Otherwise, this constitutes our splitter
        first = au[0...s]
        last = au[e...au.length]
        au = ''
      end
    end
    
    # Check for a BibTeX "suffix-part"
    if m = au.match(/(,? ((Jr|Sr|1st|2nd|3rd|IV|III|II|I)\.?))/u)
      suffix = m[2]
      s = m.begin(1)
      e = m.end(1)
      
      # If it's not at the end of the string, then it's a splitter, though
      # make sure to check for a comma
      if e != au.length
        before = au[0...s]
        after = au[e...au.length]
        
        # Carefully eat the first character (Ruby 1.8)
        if after.scan(/./mu)[0] == ','
          after = after.scan(/./mu)[1..-1].join
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
    # a comma. If au is empty, though, we've already parsed them out.
    unless au.blank?
      # Look for a comma, that's the easy method
      if m = au.match(/(,)/u)
        if m.begin(1) == 0
          # Broken string that begins w/ a comma?
          first = au.scan(/./mu)[1..-1].join
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
  
  # Create Lucene queries for the given names
  #
  # This function handles the vagaries of the formatting of an individual set
  # of names for Lucene.  There are three basic processes that this function
  # performs:
  #
  # 1. If a name is submitted by the user as a single letter, it will be 
  #    searched with a wildcard.
  # 2. If a name is submitted by the user *not* as a single letter, it will
  #    result in two queries, one with the full name and one with an initial.
  # 3. If multiple initials in a row are present, then we combine them into
  #    a single search term.
  #
  # @param [Array<String>] first list of first/middle names to use
  # @param [String] last last name to use
  # @return [Array<String>] Lucene queries for this set of names
  # @example Query without wildcards
  #   NameHelpers.query_for_names [ 'First' ], 'Last'
  #   #=> ['"F Last"', '"First Last"']
  # @example Query with wildcards
  #   NameHelpers.query_for_names [ 'F' ], 'Last'
  #   #=> ['"F* Last"']
  # @example Query with multiple forms produced
  #   NameHelpers.query_for_names [ 'First', 'Middle' ], 'Last'
  #   #=> ['"First Middle Last"', '"F Middle Last"', 
  #   #    '"First M Last"', '"F M Last"', '"FM Last"']
  def self.query_for_names(first, last)
    # Create an array of all the forms of each name
    first_name_forms = []
    
    first.each do |f|
      if f.length == 1
        # Just an initial, search it with a wildcard
        first_name_forms << [ "#{f}*" ]
      else
        # A name, search it as itself and as an initial, but without
        # a wildcard.  Be careful here on how to split on characters, for
        # compatibility with Ruby 1.8!
        first_name_forms << [ f, f.scan(/./mu)[0] ]
      end
    end
    
    # Form the list of all the names we're actually going to use
    first_name_forms_0 = first_name_forms.shift
    names = first_name_forms_0.product(*first_name_forms).map { |n| n << last }
    
    # Step through these and create the combined-initials queries
    new_names = []
    names.each do |name|
      next if name.count == 2
      
      # We want to be able to combine "First M M Last" to "First MM Last".
      # So loop over subsequences of all sizes >= 2 and <= number of first
      # names.
      (2..(name.count - 1)).each do |n|
        name.each_with_index do |p, i|
          # See if a part of the array at index i with size n is all initials
          portion = name[i, n]
          next unless portion.all? { |x| x.length == 1 || ( x.length == 2 && x[1] == '*' ) }
          
          # Create a new name with this portion merged
          new_names << [ name[0...i], "#{portion.join}", name[i+n..-1] ].flatten
        end
      end
    end
    
    names.concat(new_names)
    
    # Return the queries
    names.map { |na| "\"#{na.join(' ')}\"" }
  end
  
  # Turn an author's name into a set of Lucene queries
  #
  # When a user searches for an author by name, we want some degree of
  # fuzziness in our search results.  This function calls 
  # +NameHelpers.query_for_names+ with (1) just the first and last name, and
  # (2) the first, middle (if provided), and last names.  It also takes into
  # account the possiblity of the user providing a compact string of initials.
  #
  # @api public
  # @param [String] a the name to split
  # @return [String] the Lucene query for this author name
  # @example Add a Lucene query for W. Shatner
  #   params[:q] += "authors:(#{name_to_lucene('W. Shatner')})"
  def self.name_to_lucene(a)
    parts = NameHelpers.name_parts(a)
    
    # Construct the last name we'll use, which is last name with von part
    # and suffix w/o period
    last = ''
    last += "#{parts[:von]} " unless parts[:von].blank?
    last += parts[:last]
    last += " #{parts[:suffix].chomp('.')}" unless parts[:suffix].blank?
    
    # Quick out: if there's no parts[:first], bail
    return "\"#{last}\"" if parts[:first].blank?
    
    # Strip periods from parts[:first] and split
    first = parts[:first].gsub('.', '')
    first_names = first.split(' ')
    
    # Flatten out sequences of initials
    first_names.map! do |n|
      if n == n.upcase
        # All uppercase, so assume it's initials
        n.split(//)
      else
        n
      end
    end
    first_names.flatten!
    
    # Now, construct queries for "First Last" and "First (all middles) Last"
    queries = []
    queries.concat(NameHelpers.query_for_names([ first_names[0] ], last))
    if first_names.count > 1
      queries.concat(NameHelpers.query_for_names(first_names, last))
    end
    
    # Compose these together and return
    "(#{queries.join(" OR ")})"
  end
end
