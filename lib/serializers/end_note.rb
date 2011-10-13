# -*- encoding : utf-8 -*-

module Serializers
  
  # Convert a document to an EndNote record
  module EndNote
    # Returns this document as an EndNote record
    #
    # @api public
    # @return [String] document in EndNote format
    # @example Download this document as a enw file
    #   controller.send_data doc.to_endnote, :filename => 'export.enw', :disposition => 'attachment'
    def to_endnote
      ret  = "%0 Journal Article\n"
      formatted_author_list.each do |a|
        ret << "%A #{a[:last]}, #{a[:first]}"
        ret << " #{a[:von]}" unless a[:von].blank?
        ret << ", #{a[:suffix]}" unless a[:suffix].blank?
        ret << "\n"
      end
      ret << "%T #{title}\n" unless title.blank?
      ret << "%D #{year}\n" unless year.blank?
      ret << "%J #{journal}\n" unless journal.blank?
      ret << "%V #{volume}\n" unless volume.blank?
      ret << "%N #{number}\n" unless number.blank?
      ret << "%P #{pages}\n" unless pages.blank?
      ret << "%M #{doi}\n" unless doi.blank?
      ret << "\n"
      ret
    end
  end
end
