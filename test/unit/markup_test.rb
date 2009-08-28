require 'test_helper'

class MarkupTest < ActiveSupport::TestCase
  FIXTURES = YAML.load_file("#{Rails.root}/test/unit/markup_fixtures.yml")
  
  FIXTURES.each do |fixture|
    test fixture["title"] do
      assert_equal fixture["out"].strip, Kii::Markup.new(fixture["in"].strip).to_html
    end
  end
  
  test "preparsing page links" do
    @markup = Kii::Markup.new("[[a few]] foo bar [[page links]]")
    @markup.preparse
    assert_equal 2, @markup.page_links.length
    assert_equal ["a few", "page links"], @markup.page_links.map(&:contents)
  end
end
