# coding: UTF-8


module MARCSupport
  def MARCSupport.document_to_marc(document)
    record = MARC::Record.new()
    
    record.append(MARC::ControlField.new('001', document.shasum))
    record.append(MARC::ControlField.new('003', "PDFSHASUM"))
    record.append(MARC::ControlField.new('005', Time.now.strftime("%Y%m%d%H%M%S.0")))
    record.append(MARC::ControlField.new('008', "110501s#{sprintf '%04d', document.year}       ||||fo     ||0 0|eng d"))
    record.append(MARC::DataField.new('040', ' ', ' ',
      ['a', 'evoText'], ['b', 'eng'], ['c', 'evoText']))
    
    record.append(MARC::DataField.new('024', '7', ' ',
      ['2', 'doi'], ['a', document.doi]))
    
    parts = document.formatted_author_list[0]
    first_author = ''
    first_author << parts[:von] + ' ' unless parts[:von].blank?
    first_author << parts[:last]
    first_author << ' ' + parts[:suffix] unless parts[:suffix].blank?
    first_author << ', ' + parts[:first]
    record.append(MARC::DataField.new('100', '1', ' ',
      MARC::Subfield.new('a', first_author)))
    
    document.formatted_author_list.each do |a|
      author = ''
      author << a[:von] + ' ' unless a[:von].blank?
      author << a[:last]
      author << ' ' + a[:suffix] unless a[:suffix].blank?
      author << ', ' + a[:first]
      record.append(MARC::DataField.new('700', '1', ' ',
        MARC::Subfield.new('a', author)))
    end
    
    marc_title = document.title
    marc_title << '.' unless marc_title[-1] == '.'
    record.append(MARC::DataField.new('245', '1', '0',
      ['a', marc_title]))
    
    marc_volume = ''
    marc_volume << "v. #{document.volume}" unless document.volume.blank?
    marc_volume << " " if not document.volume.blank? and not document.number.blank?
    marc_volume << "no. #{document.number}" unless document.number.blank?
    record.append(MARC::DataField.new('490', '1', ' ',
      MARC::Subfield.new('a', document.journal),
      MARC::Subfield.new('v', marc_volume)))
    record.append(MARC::DataField.new('830', ' ', '0',
      MARC::Subfield.new('a', document.journal),
      MARC::Subfield.new('v', marc_volume)))
    
    marc_free = ''
    unless document.volume.blank?
      marc_free << "Vol. #{document.volume}"
      marc_free << (document.number.blank? ? " " : ", ")
    end
    marc_free << "no. #{document.number} " unless document.number.blank?
    marc_free << "(#{document.year})"
    marc_free << ", p. #{document.pages}" unless document.pages.blank?
    
    marc_enumeration = ''
    marc_enumeration << document.volume unless document.volume.blank?
    marc_enumeration << ":#{document.number}" unless document.number.blank?
    marc_enumeration << "<#{document.start_page}" unless document.start_page.blank?
    
    record.append(MARC::DataField.new('773', '0', ' ',
      ['t', document.journal], ['g', marc_free], 
      ['q', marc_enumeration], ['7', 'nnas']))
    
    subfields = []
    subfields << ['a', document.volume] unless document.volume.blank?
    subfields << ['b', document.number] unless document.number.blank?
    subfields << ['c', document.start_page] unless document.start_page.blank?
    subfields << ['i', document.year]
    record.append(MARC::DataField.new('363', ' ', ' ', *subfields))
    
    record.append(MARC::DataField.new('362', '0', ' ', ['a', document.year + '.']))
    
    record
  end
end