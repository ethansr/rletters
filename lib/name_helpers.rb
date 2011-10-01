
module NameHelpers
  # Split a name into its component parts
  #
  # This function applies the standard BibTeX author name splitting rules
  # to the given name.  These parsing functions aren't bulletproof, but I've
  # tried to duplicate the BibTeX parsing as much as I can, which is something
  # of an industry standard.
  #
  # @return [Hash] parts of the author's name
  #   +ret[:first]+: first name
  #   +ret[:last]+: last name
  #   +ret[:von]+: "von" part, such as "van der"
  #   +ret[:suffix]+: suffix, such as "Sr."
  def self.name_parts(a)
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
    # a comma. If au is empty, though, we've already parsed them out.
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
end
