module Kii
  # Mostly using the wikitext gem. Post-parsing to get those red links.
  class Markup
    def initialize(markup)
      @markup = CGI.escapeHTML(markup)
    end
    
    def to_html(options = {})
      return @html if defined?(@html)
      @options = options
      
      # Prepare page link parsing
      page_link_preprocessor = Kii::PageLinkPreprocessor.new(@markup, @options[:page_link])
      
      buffer = @markup.split(/(\r\n){2,}|\n{2,}/).map {|p| Paragraph.new(p).to_html }.join("\n")
      @html = with_parseable_text(buffer) {|text|
        page_link_preprocessor.parse(text)
        parse_regular_links(text)
        parse_tokens(text)
        text = @options[:post_process].call(text) if @options[:post_process]
        
        text
      }
      
      return @html
    end
    
    private
    
    # Yields all the text that is to be parsed. Returns the parsed string.
    def with_parseable_text(string)
      buffer = string.dup
      result = ''

      # This will match everything we don't want to parse, which is <nowiki>
      # tags and `code snippets`.
      while m = buffer.match(/&lt;nowiki&gt;(.*?)&lt;\/nowiki&gt;|`(.*?)`/i)
        # Everything before the match should be parsed
        result << yield(m.pre_match)
        
        # Adding the unparsed content to the results.
        if m[1] # nowiki
          result << m[1]
        elsif m[2] # code snippet
          result << inline_code_snippet(m[2])
        end
        
        # Everything after the match has not been treated yet. It will be
        # treated in the next iteration.
        buffer = m.post_match
      end

      # Everything after the last pass hasn't been parsed yet.
      result << yield(buffer)
      
      return result
    end
    
    # [http://google.com/ foo]
    def parse_regular_links(text)
      text.gsub!(/\[{1}([^ ]+) (.*?)\]{1}/) {
        %{<a href="#{$~[1]}" class="ext">#{$~[2]}</a>}
      }
    end
    
    def parse_tokens(text)
      text.gsub!(/'{3}([^']+)'{3}/, "<strong>\\1</strong>")
      text.gsub!(/'{2}([^']+)'{2}/, "<em>\\1</em>")
    end
    
    def inline_code_snippet(text)
      %{<code>#{text}</code>}
    end
  end
end