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
          ::RedCloth.new(@markup).to_html
        end
      end
    end
  end
end