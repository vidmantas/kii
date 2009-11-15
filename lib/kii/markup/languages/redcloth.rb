require "redcloth"

module Kii
  module Markup
    module Languages
      class Redcloth
        def initialize(markup, helper)
          @markup = markup
          @preprocessor = Kii::Markup::Preprocessor.new(@markup, helper)
        end
      
        def to_html
          @preprocessor.parse(@markup)
          html = ::RedCloth.new(@markup).to_html
          #@preprocessor.post_process(html)
          @preprocessor.post_process {|references|
            html << "\n"
            html << "h2. References"
            html << "\n"
            html << "References not supported with RedCloth. Sorry about that."
          }
          
          return html
        end
      end
    end
  end
end