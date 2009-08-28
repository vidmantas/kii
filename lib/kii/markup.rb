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
      preparse
      
      @html = @markup.split(/(\r\n){2,}|\n{2,}/).map {|p| Paragraph.new(p).to_html }.join("\n")
      @html.gsub!(PAGE_LINK_REGEXP) {
        permalink, title = *$~[1].split("|")
        title = (title || permalink)
        
        # Uncapitalized version, capitalized version, or does not exist (Page.new).
        page = @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink } ||
          @linked_pages.detect {|lp| lp.permalink == permalink.to_permalink.upcase_first_letter } ||
          Page.new(:title => title, :deleted => true, :permalink => permalink)
        
        options[:page_link] ? options[:page_link].call(page, title) : page.permalink
      }
      return @html
      scan_for_page_links
    end
    
    def preparse
      page_link_permalinks = @markup.scan(PAGE_LINK_REGEXP).map {|p| p[0].split("|")[0].to_permalink }
      page_link_permalinks += page_link_permalinks.map {|permalink| permalink.upcase_first_letter } # Look for capitalized as well
      page_link_permalinks.uniq!
      @linked_pages = Page.all(:conditions => {:permalink => page_link_permalinks})
    end
  end
end