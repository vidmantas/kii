module Kii
  module Markup
    def self.generate_html(markup, helper)
      Kii::Markup::Languages.const_get(Configuration[:markup].classify).new(markup, helper).to_html
    end
  end
end