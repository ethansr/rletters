# coding: UTF-8


# Class which encapsulates the export of a collection of +Document+ instances
# to RIS format.
class RISCollection
  
  # Create a new RIS collection.  +documents+ should be an array of 
  # +Document+ objects.
  def initialize(documents)
    @documents = documents
  end
  
  # Convert the array of documents to a string containing the RIS records
  # for the entire collection.
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
  
  # Convert to RIS and send to the client using the 
  # <tt>controller.send_data</tt> method of an <tt>ActionController.</tt>
  def send(controller)
    controller.send_data to_s, :filename => "export.ris", 
      :type => 'application/x-research-info-systems',
      :disposition => 'attachment'
  end
end
