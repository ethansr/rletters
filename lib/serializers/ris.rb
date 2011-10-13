# -*- encoding : utf-8 -*-

module Serializers
  
  # Convert a document to a RIS record
  module RIS
    # Returns this document as a RIS record
    #
    # @api public
    # @return [String] document in RIS format
    # @example Download this document as a ris file
    #   controller.send_data doc.to_ris, :filename => 'export.ris', :disposition => 'attachment'
    def to_ris
      ret  = "TY  - JOUR\n"
      formatted_author_list.each do |a|
        ret << "AU  - "
        ret << "#{a[:von]} " unless a[:von].blank?
        ret << "#{a[:last]},#{a[:first]}"
        ret << ",#{a[:suffix]}" unless a[:suffix].blank?
        ret << "\n"
      end
      ret << "TI  - #{title}\n" unless title.blank?
      ret << "PY  - #{year}\n" unless year.blank?
      ret << "JO  - #{journal}\n" unless journal.blank?
      ret << "VL  - #{volume}\n" unless volume.blank?
      ret << "IS  - #{number}\n" unless number.blank?
      ret << "SP  - #{start_page}\n" unless start_page.blank?
      ret << "EP  - #{end_page}\n" unless end_page.blank?
      ret << "ER  - \n"
      ret
    end
  end
end
