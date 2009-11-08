require "redcloth"

module Kii
  module Markup
    class Redcloth
      def initialize(markup, helper)
        @markup = markup
        @preprocessor = Kii::PageLinkPreprocessor.new(@markup, helper)
      end
      
      def to_html
        @preprocessor.parse(@markup)
        ::RedCloth.new(@markup).to_html
      end
    end
  end
end