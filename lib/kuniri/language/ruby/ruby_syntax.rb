require_relative 'ruby_syntax_support'
require_relative 'token_ruby'
require_relative '../language'
require_relative '../container_data/structured_and_oo/class_data'

module Languages

  # Handling the ruby syntax for extract information.
  class RubySyntax < Languages::Language

    public

      def initialize
        clear_data
      end

      def clear_data
        @rubySyntaxSupport = Languages::RubySyntaxSupport.new
        #You have to make it more generic, for the situation of many class.
        @currentClass = Languages::ClassData.new
        @classes = []
        @visibility = "public"
        @class_token = 0
        @token = 0
        @attributeList = []
        @externRequirements = []
        @functionList = []
      end

      def analyse_source(pPath)
        @name = File.basename(pPath, ".*")
        @path = File.dirname(pPath)
        analyse_first_step(pPath)
        #self.analyse_second_step
      end

      # Extract all the comments from the source.
      # @param source [String] Source code to analys.
      def comment_extract
        all_comments = Array.new
        #Find a simple Ruby comment with '#'
        @source.scan(/#(.*)/).each do |comments|
          all_comments.push(comments[0])
        end
        #Find multiple line comment.
        @source.scan(/^=begin(.*?)^=end/m).each do |comment|
          all_comments.push(comment[0].lstrip)
        end
        return all_comments
      end

      # Extract all method from the source.
      # @param source [String]
      def method_extract
        return @currentClass.get_methods
      end

      # Extract all the class declared in the source.
      # @param source [String]
      def class_extract
        return @currentClass
      end

      # @param source [String]
      def attribute_extract
        return @currentClass.get_attributes
      end

      # @param source [String]
      def global_variable_extract
        raise NotImplementedError
      end

      def extern_requirement_extract
        return @externRequirements
      end

      def dumpData
        puts "=" * 30
        puts @currentClass.dumpClassData
        puts "_" * 30
        puts extern_requirement_extract
        puts "-" * 30
        puts @functionList
        puts "-" * 30
        puts @token
      end

    private

      @class_token
      @token
      @rubySyntaxSupport
      @classes
      @currentClass
      @functionList
      attr_accessor :visibility
      @source
      @attributeList
      @externRequirements

      def analyse_first_step(pPath)
        @source = File.open(pPath, "rb")
        @source.each do |line|
          tokenType = @rubySyntaxSupport.get_token_type(line)
          if tokenType == Languages::Ruby::CLASS_TOKEN || @class_token > 0
            tokenType = @rubySyntaxSupport.get_token_type(line, true)
            handle_class(tokenType, line)
          else
            handle_nonclass(tokenType, line)
          end
        end
      end

      def increase_token
        @token = @token + 1
      end

      def handle_class(pTokenType, pLine)
        case pTokenType
          when Languages::Ruby::CLASS_TOKEN
            save_class(pLine)
          when Languages::Ruby::ATTRIBUTE_TOKEN
            save_attribute(pLine)
          when Languages::Ruby::DEF_TOKEN
            if pLine =~ /initialize/
              save_constructor(pLine)
            else
              save_method(pLine)
            end
            increase_token
          when Languages::Ruby::END_TOKEN
            @token = @token - 1
          when Languages::Ruby::VISIBILITY_TOKEN
            update_visibility(pLine)
          when Languages::Ruby::BEGIN_TOKEN
            @token = @token + 1
          when Languages::Ruby::CASE_TOKEN
            @token = @token + 1
          when Languages::Ruby::DO_TOKEN
            @token = @token + 1
          when Languages::Ruby::IF_TOKEN
            @token = @token + 1
          when Languages::Ruby::MODULE_TOKEN
            @token = @token + 1
          when Languages::Ruby::UNLESS_TOKEN
            @token = @token + 1
          else
            return
          end
      end

      def handle_nonclass(pTokenType, pLine)
        case pTokenType
          when Languages::Ruby::MODULE_TOKEN
            increase_token
          when Languages::Ruby::DEF_TOKEN
            function = @rubySyntaxSupport.get_function(pLine)
            @functionList.push(function)
            increase_token
          when Languages::Ruby::REQUIRE_TOKEN
            requirementName = @rubySyntaxSupport.get_extern_requirement(pLine)
            @externRequirements.push(requirementName)
          when Languages::Ruby::END_TOKEN
            @token = @token - 1
          else
            return
        end
        return pLine
      end

      def update_visibility(pLine)
        @visibility = @rubySyntaxSupport.get_visibiliy(pLine)
      end

      def save_class(pLine)
        @currentClass.name = @rubySyntaxSupport.get_class_name(pLine)
        @classes.push(@currentClass)
        # Get inherintance
        @class_token = @class_token + 1
        increase_token
      end

      def save_attribute(pLine)
        # TODO: Fix it!! Ugly!
        attributes = @rubySyntaxSupport.get_attribute(pLine)
        attributeName = []
        attributes.each do |attribute|
          currentAttribute = attributes.pop
          attributeName.push(currentAttribute.name)
        end
        return if @attributeList.include?(attributeName)

        @attributeList.push(attributeName)
        attributeName.each do |elementName|
          attribute = Languages::AttributeData.new(elementName)
          attribute.visibility = @visibility
          @currentClass.add_attribute(attribute)
        end
      end

      def save_constructor(pLine)
        constructor = @rubySyntaxSupport.get_constructor(pLine)
        constructor.visibility = @visibility
        @currentClass.add_constructor(constructor)
      end

      def save_method(pLine)
        method = @rubySyntaxSupport.get_method(pLine)
        method.visibility = @visibility
        @currentClass.add_method(method)
      end

  # Class
  end

# Module
end
