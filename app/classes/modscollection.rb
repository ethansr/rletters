# coding: UTF-8



class MODSCollection
  def initialize(documents)
    @documents = documents
  end
  
  def to_s
    citekeys = []
    
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.modsCollection("xmlns:xlink" => "http://www.w3.org/1999/xlink",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xmlns" => "http://www.loc.gov/mods/v3",
      "xsi:schemaLocation" => "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd") do |collection|
      @documents.each do |d|
        # We don't have a notion of "cite keys," so just take the first author's
        # last name, stripped of all non-ASCII and spaces, and the year of
        # publication, and uniquify it for the collection.
        citekey = "#{d.formatted_author_list[0][:last].gsub(' ','').gsub(/\P{ASCII}/, '')}#{d.year}"
        while citekeys.include? citekey
          citekey << 'a'
        end
        citekeys << citekey
        
        collection.mods("version" => "3.0", "ID" => citekey) do |mods|
          mods.titleInfo do |ti|
            ti.title d.title
          end
          d.formatted_author_list.each do |a|
            mods.name(:type => 'personal') do |name|
              name.namePart(a[:first], :type => 'given')
              last_name = ''
              last_name << " #{parts[:von]}" unless a[:von].blank?
              last_name << a[:last]
              last_name << ", #{parts[:suffix]}" unless a[:suffix].blank?
              name.namePart(last_name, :type => 'family')
              name.role do |role|
                role.roleTerm('author', :type => 'text', :authority => 'marcrelator')
              end
            end
          end
          mods.typeOfResource 'text'
          mods.genre 'article'
          mods.originInfo do |oi|
            oi.issuance 'monographic'
            oi.dateIssued d.year
          end
          mods.relatedItem(:type => 'host') do |ri|
            ri.titleInfo(:type => 'abbreviated') do |ti|
              ti.title d.journal
            end
            ri.originInfo do |oi|
              oi.dateIssued d.year
              oi.issuance 'continuing'
            end
            ri.genre('periodical', :authority => 'marcgt')
            ri.genre 'academic journal'
            ri.part do |part|
              unless d.volume.blank?
                part.detail(:type => 'volume') do |det|
                  det.number d.volume
                end
              end
              unless d.number.blank?
                part.detail(:type => 'issue') do |det|
                  det.number d.number
                  det.caption 'no.'
                end
              end
              unless d.pages.blank?
                part.extent(:unit => 'page') do |e|
                  e.start d.start_page unless d.start_page.blank?
                  e.end d.end_page unless d.end_page.blank?
                end
              end
              part.date d.year
            end
          end
          mods.identifier(d.doi, :type => 'doi') unless d.doi.blank?
        end
      end
    end
    
    xml.target!.to_s
  end
    
  def send(controller)
    controller.send_data to_s, :filename => "export_mods.xml", 
      :type => 'application/mods+xml', :disposition => 'attachment'
  end
end
