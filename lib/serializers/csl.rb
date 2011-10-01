require 'CiteProc'

module Serializers
  module CSL
    # Returns a hash representing the article in CSL format
    #
    # @return [Hash] article as a CSL record
    def to_csl
      ret = {}
      ret['type'] = 'article-journal'

      if self.formatted_author_list && self.formatted_author_list.count
        ret['author'] = []
     
        self.formatted_author_list.each do |a|
          h = {}
          h['given'] = a[:first]
          h['family'] = a[:last]
          h['suffix'] = a[:suffix]
          h['non-dropping-particle'] = a[:von]

          ret['author'] << h
        end
      end
      
      ret['title'] = self.title if self.title
      ret['container-title'] = self.journal if self.journal
      ret['issued'] = { 'date-parts' => [[ Integer(self.year) ]] } if self.year
      ret['volume'] = self.volume if self.volume
      ret['issue'] = self.number if self.number
      ret['page'] = self.pages if self.pages

      ret
    end

    def to_csl_entry(style = '')
      style = 'chicago-author-date.csl' if style.blank?
      style = Rails.root.join('vendor', 'csl', style) unless style.match(/\Ahttps?:/)

      CiteProc.process(to_csl, :format => :html, :style => style).strip.html_safe
    end
  end
end
