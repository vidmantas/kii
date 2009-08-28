module Kii
  class Markup
    class PageLink
      attr_reader :contents
      
      def initialize(contents)
        @contents = contents
      end
    end
  end
end