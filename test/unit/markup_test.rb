require 'test_helper'

class MarkupTest < ActiveSupport::TestCase
  FIXTURES = YAML.load_file("#{Rails.root}/test/unit/markup_fixtures.yml")
  
  FIXTURES.each do |fixture|
    test fixture["title"] do
      assert_equal fixture["out"].strip, Kii::Markup.new(fixture["in"].strip).to_html
    end
  end
  
  test "handling page links" do
    @markup = Kii::Markup.new("[[a few]] foo bar [[page links]]")
    html = @markup.to_html :page_link => proc {|page, title| page.new_record? }
    assert_equal html, "<p>true foo bar true</p>"
  end
  
  test "custom titles" do
    @markup = Kii::Markup.new("[[link|Custom title]]")
    html = @markup.to_html :page_link => proc {|page, title| title }
    assert_equal html, "<p>Custom title</p>"
  end
  
  test "lowercased too" do
    @markup = Kii::Markup.new("[[can I be lowercased]]")
    html = @markup.to_html :page_link => proc {|page, title| page.title }
    assert_equal html, "<p>can I be lowercased</p>"
  end
end
