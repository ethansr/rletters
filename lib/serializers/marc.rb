# -*- encoding : utf-8 -*-

module Serializers
  
  # Convert a document to a MARC record
  module MARC
    # Returns this document as a MARC::Record object
    #
    # Support for individual-article MARC records is spotty at best -- this is
    # a use case for which the MARC format was not intended.  To generate
    # these records, we primarily follow the adbice as presented in
    # {PROPOSAL 2003-03}[http://www.loc.gov/marc/marbi/2003/2003-03.html],
    # "Definition of Data Elements for Article Level Descsription."  We also
    # adhere to the prior standard of providing a "free-form" citation entry
    # in field, 773, subfield $g (Host Item Entry, Related Parts).  This
    # should ensure a reasonable degree of compatibility.
    #
    # In cases where significant parts of a document record are missing (i.e.,
    # no author, no title, no year), it is possible that the MARC generated
    # by this method will be invalid.
    #
    # @api public
    # @return [MARC::Record] document as a MARC record
    # @example Write out this document as MARC-XML
    #   writer = MARC::XMLWriter.new('marc.xml')
    #   writer.write(doc.to_marc)
    #   writer.close()
    def to_marc
      record = ::MARC::Record.new()

      record.append(::MARC::ControlField.new('001', shasum))
      record.append(::MARC::ControlField.new('003', "PDFSHASUM"))
      record.append(::MARC::ControlField.new('005', Time.now.strftime("%Y%m%d%H%M%S.0")))
      
      if year.blank?
        year_control = '0000'
      else
        year_control = sprintf '%04d', year
      end
      record.append(::MARC::ControlField.new('008', "110501s#{year_control}       ||||fo     ||0 0|eng d"))
      
      record.append(::MARC::DataField.new('040', ' ', ' ',
        ['a', 'RLetters'], ['b', 'eng'], ['c', 'RLetters']))

      unless doi.blank?
        record.append(::MARC::DataField.new('024', '7', ' ',
          ['2', 'doi'], ['a', doi]))
      end

      unless authors.blank?
        record.append(::MARC::DataField.new('100', '1', ' ',
          ::MARC::Subfield.new('a', author_to_marc(formatted_author_list[0]))))
      end

      formatted_author_list.each do |a|
        record.append(::MARC::DataField.new('700', '1', ' ',
          ::MARC::Subfield.new('a', author_to_marc(a))))
      end

      unless title.blank?
        marc_title = title
        marc_title << '.' unless marc_title[-1] == '.'
        record.append(::MARC::DataField.new('245', '1', '0',
          ['a', marc_title]))
      end

      marc_volume = ''
      marc_volume << "v. #{volume}" unless volume.blank?
      marc_volume << " " if not volume.blank? and not number.blank?
      marc_volume << "no. #{number}" unless number.blank?
      record.append(::MARC::DataField.new('490', '1', ' ',
        ::MARC::Subfield.new('a', journal),
        ::MARC::Subfield.new('v', marc_volume)))
      record.append(::MARC::DataField.new('830', ' ', '0',
        ::MARC::Subfield.new('a', journal),
        ::MARC::Subfield.new('v', marc_volume)))

      marc_free = ''
      unless volume.blank?
        marc_free << "Vol. #{volume}"
        marc_free << (number.blank? ? " " : ", ")
      end
      marc_free << "no. #{number} " unless number.blank?
      marc_free << "(#{year})" unless year.blank?
      marc_free << ", p. #{pages}" unless pages.blank?

      marc_enumeration = ''
      marc_enumeration << volume unless volume.blank?
      marc_enumeration << ":#{number}" unless number.blank?
      marc_enumeration << "<#{start_page}" unless start_page.blank?

      record.append(::MARC::DataField.new('773', '0', ' ',
        ['t', journal], ['g', marc_free], 
        ['q', marc_enumeration], ['7', 'nnas']))

      subfields = []
      subfields << ['a', volume] unless volume.blank?
      subfields << ['b', number] unless number.blank?
      subfields << ['c', start_page] unless start_page.blank?
      subfields << ['i', year] unless year.blank?
      record.append(::MARC::DataField.new('363', ' ', ' ', *subfields))

      unless year.blank?
        record.append(::MARC::DataField.new('362', '0', ' ', ['a', year + '.']))
      end

      record
    end
    
    
    # Returns this document in MARC21 transmission format
    #
    # @note No tests for this method, as it is implemented by the MARC gem.
    # @api public
    # @return [String] document in MARC21 transmission format
    # @example Download this document as a marc file
    #   controller.send_data doc.to_marc21, :filename => 'export.marc', :disposition => 'attachment'
    # :nocov:
    def to_marc21
      to_marc.to_marc
    end
    # :nocov:
    
    # Returns this document in MARC JSON format
    #
    # MARC in JSON is the newest and shiniest way to transmit MARC records.
    #
    # @note No tests for this method, as it is implemented by the MARC gem.
    # @api public
    # @return [String] document in MARC JSON format
    # @example Download this document as a MARC-JSON file
    #   controller.send_data doc.to_marc_json, :filename => 'export.json', :disposition => 'attachment'
    # :nocov
    def to_marc_json
      to_marc.to_hash.to_json
    end
    # :nocov
    
    # Returns this document as MARC-XML
    #
    # This method will include the XML namespace declarations in the root
    # element by default, making this document suitable to be saved
    # standalone.  Pass +false+ to get a plain root element, suitable for 
    # inclusion in a MARC collection.
    #
    # @note No tests for this method, as it is implemented by the MARC gem.
    # @api public
    # @param [Boolean] include_namespace if false, put no namespace in the
    #   root element
    # @return [REXML::Document] the document as a MARC-XML document
    # @example Output the document as MARC-XML in a string
    #   ret = ''
    #   doc.to_marc_xml.write(ret, 2)
    # :nocov:
    def to_marc_xml(include_namespace = false)
      ::MARC::XMLWriter.encode(to_marc, :include_namespace => include_namespace)
    end
    # :nocov:
    
    private
    
    # Convert the given author (from +formatted_author_list+) to MARC's format
    # @api private
    # @param [Hash] a author from +formatted_author_list+
    # @return [String] author formatted as MARC expects it
    def author_to_marc(a)
      author = ''
      author << a[:von] + ' ' unless a[:von].blank?
      author << a[:last]
      author << ' ' + a[:suffix] unless a[:suffix].blank?
      author << ', ' + a[:first]
      author
    end
  end
end

