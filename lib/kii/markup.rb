module Kii
  # Mostly using the wikitext gem. Post-parsing to get those red links.
  class Markup
    PAGE_LINK_REGEXP = /\[\[(.*?)\]\]/
    attr_reader :linked_pages
    
    def initialize(markup)
      @markup = CGI.escapeHTML(markup)
    end
    
    def to_html(options = {})
      return @html if defined?(@html)
      @options = options
      
      preparse

      buffer = @markup.split(/(\r\n){2,}|\n{2,}/).map {|p| Paragraph.new(p).to_html }.join("\n")
      @html = with_parseable_text(buffer) {|text|
        parse_page_links(text)
        parse_regular_links(text)
        parse_tokens(text)
        text = @options[:post_process].call(text) if @options[:post_process]
        
        text
      }
      
      return @html
    end
    
    # Finding all pages, fetching them from the DB, to avoid N+1 when parsing page links
    # later on.
    def preparse
      page_link_permalinks = @markup.scan(PAGE_LINK_REGEXP).map {|p| p[0].split("|")[0].to_permalink }
      page_link_permalinks += page_link_permalinks.map {|permalink| permalink.upcase_first_letter } # Look for capitalized as well
      page_link_permalinks.uniq!
      @linked_pages = Page.all(:conditions => {:permalink => page_link_permalinks})
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
    
    # [[Foo]] and [[Foo|Bar]]
    def parse_page_links(text)
      text.gsub!(PAGE_LINK_REGEXP) {
        permalink, title = *$~[1].split("|")
        title = (title || permalink)
        
        # Uncapitalized version, capitalized version, or does not exist (Page.new).
        page = @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink } ||
          @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink.upcase_first_letter } ||
          Page.new(:title => title, :deleted => true, :permalink => permalink)
        
        @options[:page_link] ? @options[:page_link].call(page, title) : page.permalink
      }
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