module Kii
  module Markup
    # Syntax generic to all markup languages are handled here, such as page links,
    # references etc.
    #
    # It proceccess in two passes. The first time, initialize, it reads out all
    # the page links and fetches the pages from the database. The second time it
    # performs the actual parsing, replacing page link syntax with HTML links and
    # so on.
    class Preprocessor
      PAGE_LINK_REGEXP = /\[\[(.*?)\]\]/
      
      def initialize(markup, helper)
        @markup, @helper = markup, helper
        @references = []

        page_link_permalinks = @markup.scan(PAGE_LINK_REGEXP).map {|p| p[0].split("|")[0].to_permalink }
        page_link_permalinks += page_link_permalinks.map {|permalink| permalink.upcase_first_letter } # Look for capitalized as well
        page_link_permalinks.uniq!
        @linked_pages = Page.all(:conditions => {:permalink => page_link_permalinks})
      end

      def parse(text)
        parse_page_links(text)
        parse_references(text)
        
        return text
      end
      
      def post_process(html)
        if !@references.empty?
          html << "\n<h2>References</h2>\n"
          html << %{<ol id="references">}
          
          @references.each_with_index {|ref, i|
            html << %{<li id="#{reference_key(i + 1)}">#{@helper.auto_link(ref)}</li>}
          }
          html << "</ol>"
        end
      end
      
      private
      
      def parse_page_links(text)
        text.gsub!(PAGE_LINK_REGEXP) {
          permalink, title = *$~[1].split("|")
          title = (title || permalink)

          # Uncapitalized version, capitalized version, or does not exist (Page.new).
          page = @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink } ||
            @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink.upcase_first_letter } ||
            Page.new(:title => title, :deleted => true, :permalink => permalink)

          @helper.page_link(page, title)
        }
      end
        
      def parse_references(text)
        text.gsub!(/\[ref:(.*?)\]/) {
          ref = $~[1]
          @references << ref
          index = @references.index(ref) + 1
          %{<a href="##{reference_key(index)}" class="reference">&#91;#{index}&#93;</a>}
        }
      end
      
      def reference_key(index)
        "ref-#{index}"
      end
    end
  end
end