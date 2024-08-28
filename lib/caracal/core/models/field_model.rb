require 'caracal/core/models/base_model'

module Caracal
  module Core
    module Models
      # This class encapsulates the logic needed to store and manipulate
      # text data.
      #
      class FieldModel < BaseModel
        #--------------------------------------------------
        # Configuration
        #--------------------------------------------------

        # constants
        const_set(:TYPE_MAP, { page: 'PAGE', numpages: 'NUMPAGES' })

        # accessors
        attr_reader :field_dirty, :field_type, :field_style, :field_font, :field_color,
                    :field_size, :field_bold, :field_italic, :field_underline, :field_bgcolor,
                    :field_highlight_color, :field_vertical_align

        #-------------------------------------------------------------
        # Public Class Methods
        #-------------------------------------------------------------

        def self.formatted_type(type)
          TYPE_MAP.fetch(type.to_s.to_sym)
        end

        #-------------------------------------------------------------
        # Public Instance Methods
        #-------------------------------------------------------------

        #=============== GETTERS ==============================

        def formatted_type
          self.class.formatted_type(field_type)
        end

        # .run_attributes
        def run_attributes
          {
            style: field_style,
            font: field_font,
            color: field_color,
            size: field_size,
            bold: field_bold,
            italic: field_italic,
            underline: field_underline,
            bgcolor: field_bgcolor,
            highlight_color: field_highlight_color,
            vertical_align: field_vertical_align
          }
        end

        #========== SETTERS ===============================

        # booleans
        %i(bold italic underline).each do |m|
          define_method "#{m}" do |value|
            instance_variable_set("@field_#{m}", !!value)
          end
        end

        # integers
        [:size].each do |m|
          define_method "#{m}" do |value|
            instance_variable_set("@field_#{m}", value.to_i)
          end
        end

        # strings
        %i(bgcolor color dirty font highlight_color style type).each do |m|
          define_method "#{m}" do |value|
            instance_variable_set("@field_#{m}", value.to_s)
          end
        end

        # symbols
        [:vertical_align].each do |m|
          define_method "#{m}" do |value|
            instance_variable_set("@field_#{m}", value.to_s.to_sym)
          end
        end

        #========== VALIDATION ============================

        def valid?
          a = [:type]
          a.filter_map { |m| send("field_#{m}") }.size == a.size
        end

        private

        def option_keys
          %i(type style font color size bold italic underline bgcolor highlight_color vertical_align)
        end
      end
    end
  end
end
