require 'nokogiri'
require_relative '../language/class_data'

module Parser

  class XML

    def initialize(path = "/tmp/kuniri.xml")
      set_path(path)
    end

    def set_path(path)
      @parser_path = path
    end

    # Create the xml output file.
    #   only saves a single ClassData for now
    # @param class_data [ClassData] Receives the ClassData to save
    def create(class_data)
      builder = Nokogiri::XML::Builder.new do |xml|
        generate_class(xml, class_data)
      end

      @builder = builder

      File.open(@parser_path, 'w') do |file|
        file.write(builder.to_xml)
      end
    end

    # returns the builder if create method already executed
    def get_builder
      @builder
    end

    # Parse a ClassData to xml
    # @param xml [Nokogiri::XML::Builder] xml builder to edit
    # @param class_data [ClassData] the ClassData to save
    def generate_class(xml, class_data)
      xml.class_data(:name => class_data.name.first) {
        xml.methods_ {
          class_data.get_methods.each do |o|
            generate_method(xml, o)
          end
        }
      }
    end

    # Parse a MethodData to xml
    # @param xml [Nokogiri::XML::Builder] xml builder to edit
    # @param class_data [MethodData] the MethodData to save
    def generate_method(xml, method_data)
      xml.method_(:name => method_data.name.first) {
        method_data.get_parameters.each do |p|
          generate_parameter(xml, p)
        end
      }
    end

    # Parse a MethodData to xml
    # @param xml [Nokogiri::XML::Builder] xml builder to edit
    # @param class_data [String] the Attribute to save
    def generate_parameter(xml, parameter)
      xml.parameter {
        xml.name = parameter
      }
    end

  end
end
