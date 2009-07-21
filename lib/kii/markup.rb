module Kii
  # Mostly using the wikitext gem. Post-parsing to get those red links.
  class Markup
    PARSER = Wikitext::Parser.new
    # We look for this prefix in the post parsing, so that we can separate page links from
    # other <a> tags. 
    PARSER.internal_link_prefix = "internal_prefix"
    
    PAGE_LINK_REGEX = %r{<a href="#{PARSER.internal_link_prefix}(.*?)">(.*?)</a>}
    
    def initialize(markup, helper)
      @markup, @helper = markup, helper
    end
    
    def to_html
      return @html if defined?(@html)
      
      parse_markup
      preparse_linked_pages
      create_page_links
            
      return @html
    end
    
    private
    
    # base_heading_level lets us start on h2, since there's already a h1 on all pages.
    def parse_markup
      @html = PARSER.parse(@markup, :base_heading_level => 1)
    end
    
    def preparse_linked_pages
      permalinks = []
      # First, the actual permalinks
      @html.scan(PAGE_LINK_REGEX) {|match| permalinks << CGI.unescape(match[0]).to_permalink }
      # Then, we add the capitalized version, to allow linking to both [[home]] and [[Home]].
      permalinks += permalinks.map {|permalink| permalink.upcase_first_letter }
      permalinks.uniq!
      
      @linked_pages = Page.all(:conditions => {:permalink => permalinks, :deleted => false})
    end
    
    def create_page_links
      @html.gsub!(PAGE_LINK_REGEX) {
        link_text = ($~[2] || $~[1])
        permalink = CGI.unescape($~[1])
        
        page = @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink } ||
          @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink.upcase_first_letter } ||
          Page.new(:title => link_text, :deleted => true, :permalink => permalink)
          
        
        @helper.page_link(page, link_text)
      }
    end
  end
end