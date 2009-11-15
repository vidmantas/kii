module Kii
  class Markup
    PAGE_LINK_REGEXP = /\[\[(.*?)\]\]/
    
    def initialize(markup)
      @markup = CGI.escapeHTML(markup)
    end
    
    def to_html(&block)
      fetch_linked_pages_from_database
      
      @markup.gsub!("\r\n", "\n") # Rails some times outputs \r\n instead of \n.
      buffer = @markup.split(/(?:\n(?= {2,})){2,}|\n{2,}/).map {|p| Paragraph.new(p).to_html }.join("\n")
      
      with_parseable_text(buffer) {|text|
        parse_page_links(text, block)
        parse_regular_links(text)
        parse_tokens(text)
        text
      }
    end
    
    private
    
    def fetch_linked_pages_from_database
      page_link_permalinks = @markup.scan(PAGE_LINK_REGEXP).map {|p| p[0].split("|")[0].to_permalink }
      page_link_permalinks += page_link_permalinks.map {|permalink| permalink.upcase_first_letter } # Look for capitalized as well
      page_link_permalinks.uniq!
      @linked_pages = Page.all(:conditions => {:permalink => page_link_permalinks})
    end
    
    # Scans through the markup and yields stuff that should be parsed. That means
    # it won't yield stuff inside nowiki tags, and so on.
    def with_parseable_text(markup)
      buffer = markup.dup
      result = []

      while m = buffer.match(/&lt;nowiki&gt;(.*?)&lt;\/nowiki&gt;|`(.*?)`/i)
        result << yield(m.pre_match)

        if m[1] # nowiki
          result << m[1]
        elsif m[2] # code snippet
          result << inline_code_snippet(m[2])
        end

        buffer = m.post_match
      end

      result << yield(buffer)

      return result.join
    end
    
    def parse_page_links(text, page_link_proc)
      text.gsub!(PAGE_LINK_REGEXP) {
        permalink, title = *$~[1].split("|")
        title = (title || permalink)

        # Uncapitalized version, capitalized version, or does not exist (Page.new).
        page = @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink } ||
          @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink.upcase_first_letter } ||
          Page.new(:title => title, :deleted => true, :permalink => permalink)

        page_link_proc.call(page, title)
      }
    end
    
    # [http://google.com/ foo]
    def parse_regular_links(text)
      text.gsub!(/\[{1}([^ ]+)(?: (.*?))?\]{1}/) {
        href = $~[1]
        title = $~[2] || href
        %{<a href="#{href}" class="ext">#{title}</a>}
      }
    end

    def parse_tokens(text)
      text.gsub!(/'{3}([^']+)'{3}/, "<strong>\\1</strong>")
      text.gsub!(/'{2}([^']+)'{2}/, "<em>\\1</em>")
    end
    
    def parse_references(text)
      text.gsub!(/\[ref:(.*?)\]/) {
        ref = $~[1]
        @references << ref
        index = @references.index(ref) + 1
        %{<a href="#ref-#{index}" class="reference">&#91;#{index}&#93;</a>}
      }
    end

    def inline_code_snippet(text)
      %{<code>#{text}</code>}
    end
  end
end