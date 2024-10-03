require 'nokogiri'

require 'caracal/core/models/list_style_model'
require 'caracal/core/models/list_model'
require 'caracal/renderers/xml_renderer'

module Caracal
  module Renderers
    class NumberingRenderer < XmlRenderer

      #-------------------------------------------------------------
      # Public Methods
      #-------------------------------------------------------------

      # This method produces the xml required for the `word/numbering.xml`
      # sub-document.
      #
      def to_xml
        builder = ::Nokogiri::XML::Builder.with(declaration_xml) do |xml|
          xml['w'].numbering root_options do
            # add abstract definitions
            document.toplevel_lists.each_with_index do |model, i|
              xml['w'].abstractNum({ 'w:abstractNumId' => i + 2 }) do
                xml['w'].multiLevelType({ 'w:val' => 'hybridMultilevel' })
                model.level_map.each do |(level, type)|
                  if s = document.find_list_style(type, level)
                    xml['w'].lvl({ 'w:ilvl' => s.style_level }) do
                      xml['w'].start({ 'w:val' => s.style_start })
                      xml['w'].numFmt({ 'w:val' => s.style_format })
                      xml['w'].lvlRestart({ 'w:val' => s.style_restart })
                      xml['w'].lvlText({ 'w:val' => s.style_value })
                      xml['w'].lvlJc({ 'w:val' => s.style_align })
                      xml['w'].pPr do
                        xml['w'].ind({ 'w:left' => s.style_left, 'w:firstLine' => s.style_indent })
                      end
                      xml['w'].rPr do
                        xml['w'].u({ 'w:val' => 'none' })
                      end
                    end
                  end
                end
              end
            end

            # bind individual tables to abstract definitions
            document.toplevel_lists.each_with_index do |model, i|
              xml['w'].num({ 'w:numId' => i + 2 }) do
                xml['w'].abstractNumId({ 'w:val' => i + 2 })
              end
            end

            if %w(Heading1 Heading2 Heading3 Heading4).any? do |style_name|
              document.styles.find { |style| style.style_id == style_name }&.style_level.present?
            end
              xml['w'].abstractNum({ 'w:abstractNumId' => 1 }) do
                xml['w'].multiLevelType({ 'w:val' => 'hybridMultilevel' })
                create_lvl(xml, 0, 'Heading1', '%1.')
                create_lvl(xml, 1, 'Heading2', '%1.%2.')
                create_lvl(xml, 2, 'Heading3', '%1.%2.%4.')
                create_lvl(xml, 3, 'Heading4', '%1.%2.%4.%5.')
              end

              xml['w'].num({ 'w:numId' => 1 }) do
                xml['w'].abstractNumId({ 'w:val' => 1 })
              end
            end
          end
        end
        builder.to_xml(save_options)
      end



      #-------------------------------------------------------------
      # Private Methods
      #-------------------------------------------------------------
      private

      def root_options
        {
          'xmlns:mc'  => 'http://schemas.openxmlformats.org/markup-compatibility/2006',
          'xmlns:o'   => 'urn:schemas-microsoft-com:office:office',
          'xmlns:r'   => 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
          'xmlns:m'   => 'http://schemas.openxmlformats.org/officeDocument/2006/math',
          'xmlns:v'   => 'urn:schemas-microsoft-com:vml',
          'xmlns:wp'  => 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
          'xmlns:w10' => 'urn:schemas-microsoft-com:office:word',
          'xmlns:w'   => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
          'xmlns:wne' => 'http://schemas.microsoft.com/office/word/2006/wordml',
          'xmlns:sl'  => 'http://schemas.openxmlformats.org/schemaLibrary/2006/main',
          'xmlns:a'   => 'http://schemas.openxmlformats.org/drawingml/2006/main',
          'xmlns:pic' => 'http://schemas.openxmlformats.org/drawingml/2006/picture',
          'xmlns:c'   => 'http://schemas.openxmlformats.org/drawingml/2006/chart',
          'xmlns:lc'  => 'http://schemas.openxmlformats.org/drawingml/2006/lockedCanvas',
          'xmlns:dgm' => 'http://schemas.openxmlformats.org/drawingml/2006/diagram'
        }
      end

      def create_lvl(xml, ilvl, p_style, lvl_text)
        if document.styles.find { |style| style.style_id == p_style }.style_level == ilvl
          padding = 430 + (140 * ilvl)
          xml['w'].lvl({ 'w:ilvl' => ilvl }) do
            xml['w'].start({ 'w:val' => 1 })
            xml['w'].numFmt({ 'w:val' => 'decimal' })
            xml['w'].pStyle({ 'w:val' => p_style })
            xml['w'].lvlText({ 'w:val' => lvl_text })
            xml['w'].lvlJc({ 'w:val' => 'left' })
            xml['w'].pPr do
              xml['w'].ind({ 'w:left' => padding, 'w:hanging' => padding })
            end
          end
        end
      end
    end
  end
end
