# coding: UTF-8


class RISCollection
  def initialize(documents)
    @documents = documents
  end
  
  def to_s
    ret = ""
    
    @documents.each do |d|
      ret << "TY  - JOUR\n"
      d.formatted_author_list.each do |a|
        ret << "AU  - "
        ret << "#{a[:von]} " unless a[:von].blank?
        ret << "#{a[:last]},#{a[:first]}"
        ret << ",#{a[:suffix]}" unless a[:suffix].blank?
        ret << "\n"
      end
      ret << "TI  - #{d.title}\n"
      ret << "PY  - #{d.year}///\n"
      ret << "JO  - #{d.journal}\n"
      ret << "VL  - #{d.volume}\n" unless d.volume.blank?
      ret << "IS  - #{d.number}\n" unless d.number.blank?
      ret << "SP  - #{d.start_page}\n" unless d.start_page.blank?
      ret << "EP  - #{d.end_page}\n" unless d.end_page.blank?
      ret << "ER  - \n"
    end
    
    ret
  end
  
  def send(controller)
    controller.send_data to_s, :filename => "evotext_export.ris", 
      :type => 'application/x-research-info-systems',
      :disposition => 'attachment'
  end
end
