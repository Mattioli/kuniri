require_relative 'attribute_ruby'
require_relative 'token_ruby'
require_relative 'class_ruby'
require_relative 'extern_requirement_ruby'
require_relative 'function_behavior_ruby'
require_relative '../container_data/structured_and_oo/method_data'
require_relative '../container_data/structured_and_oo/attribute_data'
require_relative '../container_data/structured_and_oo/constructor_data'

module Languages

  # This class implements useful methods for help to handling Ruby syntax.
  class RubySyntaxSupport

    def initialize
      @attributeRuby = Languages::Ruby::AttributeRuby.new
      @classRuby = Languages::Ruby::ClassRuby.new
      @externRequirement = Languages::Ruby::ExternRequirementRuby.new
      @functionBehavior = Languages::Ruby::FunctionBehaviorRuby.new
    end

    def apply_regex(pLine, pRegex)
      result = pLine.scan(pRegex)[0]

      return nil unless result
      return result
    end

    def get_class_name(pLine)
      return @classRuby.get_class(pLine)
    end

    def get_attribute(pLine)
      return  @attributeRuby.get_attribute(pLine)
    end

    def get_function(pLine)
      return @functionBehavior.get_function(pLine, "globalFunction")
    end

    def get_method(pLine)
      return @functionBehavior.get_function(pLine, "method")
    end

    def get_constructor(pLine)
      return @functionBehavior.get_function(pLine, "constructor")
    end

    def get_extern_requirement(pLine)
      return @externRequirement.get_requirement(pLine)
    end

    def get_begin(pLine)
      regexExpression = /^\s+begin|^begin/
      return apply_regex(pLine, regexExpression)
    end

    def get_case(pLine)
      regexExpression = /^\s+case|^case/
      return apply_regex(pLine, regexExpression)
    end

    def get_do(pLine)
      regexExpression = /\s+do\s+|^do\s+|\s+do|^do/
      return apply_regex(pLine, regexExpression)
    end

    def get_if(pLine)
      regexExpression = /^\s+if|^if/
      return apply_regex(pLine, regexExpression)
    end

    def get_module(pLine)
      regexExpression = /^\s+module|^module/
      return apply_regex(pLine, regexExpression)
    end

    def get_unless(pLine)
      regexExpression = /^\s+unless|^unless/
      return apply_regex(pLine, regexExpression)
    end

    def has_end?(pLine)
      return true if pLine =~ /^\s+end|^end/
      return false
    end

    def get_visibiliy(pLine)
      regexExpression = 
              /^\sprivate|^private|^\spublic|^public|^\sprotected|^protected/
      return apply_regex(pLine, regexExpression)
    end

    def get_token_type(pLine, pClass_token=false)
      # Special token for class
      if pClass_token
        if @attributeRuby.get_attribute(pLine)
          return Ruby::ATTRIBUTE_TOKEN 
        elsif get_visibiliy(pLine)
          return Ruby::VISIBILITY_TOKEN
        end
      end

      # All of these reserved words are close with "end"
      if @classRuby.get_class(pLine)
        return Ruby::CLASS_TOKEN
      elsif has_end?(pLine)
        return Ruby::END_TOKEN
      elsif get_begin(pLine)
        return Ruby::BEGIN_TOKEN
      elsif @functionBehavior.get_function(pLine)
        return Ruby::DEF_TOKEN
      elsif get_case(pLine)
        return Ruby::CASE_TOKEN
      elsif get_do(pLine)
        return Ruby::DO_TOKEN
      elsif get_if(pLine)
        return Ruby::IF_TOKEN
      elsif get_module(pLine)
        return Ruby::MODULE_TOKEN
      elsif get_unless(pLine)
        return Ruby::UNLESS_TOKEN
      end

      # Other reserved words
      if @externRequirement.get_requirement(pLine)
        return Ruby::REQUIRE_TOKEN
      #elsif ...
      end
    end

  #end of class
  end

#end of module
end
