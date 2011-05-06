
class EndNoteCollection
  def initialize(documents)
    @documents = documents
  end
  
  def to_s
    ret = ""
    
    @documents.each do |d|
      ret << "%0 Journal Article\n"
      d.formatted_author_list.each do |a|
        ret << "%A #{a[:last]}, #{a[:first]}"
        ret << " #{a[:von]}" unless a[:von].blank?
        ret << ", #{a[:suffix]}" unless a[:suffix].blank?
        ret << "\n"
      end
      ret << "%T #{d.title}\n"
      ret << "%D #{d.year}\n"
      ret << "%J #{d.journal}\n"
      ret << "%V #{d.volume}\n" unless d.volume.blank?
      ret << "%N #{d.number}\n" unless d.number.blank?
      ret << "%P #{d.pages}\n" unless d.pages.blank?
      ret << "%M #{d.doi}\n" unless d.doi.blank?
      ret << "\n"
    end
    
    ret
  end
  
  def send(controller)
    controller.send_data to_s, :filename => "evotext_export.enw", 
      :type => 'application/x-endnote-refer', :disposition => 'attachment'
  end
end
