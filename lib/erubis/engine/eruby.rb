##
## $Rev$
## $Release$
## $Copyright$
##

require 'erubis/engine'
require 'erubis/enhancer'
require 'abstract'


module Erubis


  ##
  ## code generator for Ruby
  ##
  module RubyGenerator
    include Generator
    #include StringBufferEnhancer
    include ArrayBufferEnhancer

    def init_generator(properties={})
      super
      @escapefunc ||= "Erubis::XmlHelper.escape_xml"
    end

    def self.supported_properties()  # :nodoc:
      return []
    end

    def escape_text(text)
      text.gsub(/['\\]/, '\\\\\&')   # "'" => "\\'",  '\\' => '\\\\'
    end

    #--
    #def add_preamble(src)
    #  src << "_buf = [];"
    #end
    #++

    def add_text(src, text)
      src << " _buf << '" << escape_text(text) << "';" unless text.empty?
    end

    def add_stmt(src, code)
      #src << code << ';'
      src << code
      src << ';' unless code[-1] == ?\n
    end

    def add_expr_literal(src, code)
      src << ' _buf << (' << code << ').to_s;'
    end

    def add_expr_escaped(src, code)
      src << " _buf << #{@escapefunc}(#{code});"
    end

    def add_expr_debug(src, code)
      code.strip!
      s = (code.dump =~ /\A"(.*)"\z/) && $1
      src << ' $stderr.puts("*** debug: ' << s << '=#{(' << code << ').inspect}");'
    end

    #--
    #def add_postamble(src)
    #  src << "\n_buf.join\n"
    #end
    #++

  end


  ##
  ## engine for Ruby
  ##
  class Eruby < Basic::Engine
    include RubyEvaluator
    include RubyGenerator
  end


  ##
  ## swtich '<%= %>' to escaped and '<%== %>' to not escaped
  ##
  class EscapedEruby < Eruby
    include EscapeEnhancer
  end


  ##
  ## sanitize expression (<%= ... %>) by default
  ##
  ## this is equivalent to EscapedEruby and is prepared only for compatibility.
  ##
  class XmlEruby < Eruby
    include EscapeEnhancer
  end


  class PI::Eruby < PI::Engine
    include RubyEvaluator
    include RubyGenerator

    def init_converter(properties={})
      @pi = 'rb'
      super(properties)
    end

  end


end
