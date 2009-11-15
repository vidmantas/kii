require "test_helper"

# Most of the syntax related stuff is covered in the integration test.
class MarkupUnitTest < ActiveSupport::TestCase
  test "loading page links from database" do
    p1 = Factory.create(:page, :title => "My page")
    p2 = Factory.create(:page, :title => "Another page")
    
    assert_pages_used "Here's [[My page]] and [[Another page]]", p1, p2
  end
  
  test "page link matches uppercased pages on lowercased page link" do
    @page = Factory.create(:page, :title => "Hullo")
    
    assert_pages_used "[[hullo]]", @page
  end
  
  test "lowercased page link with both lowercased and uppercased page present" do
    p1 = Factory.create(:page, :title => "Hullo")
    p2 = Factory.create(:page, :title => "hullo")
    
    assert_pages_used "[[Hullo]]", p1
    assert_pages_used "[[hullo]]", p2
  end
  
  test "page link with custom title" do
    @page = Factory.create(:page, :title => "Some page")
    
    assert_pages_used "[[Some page|Custom title]]", @page
  end
  
  private
  
  def assert_pages_used(markup, *pages)
    markup = Kii::Markup.new(markup)
    used_pages = []
    markup.to_html {|page, title| used_pages << page }
    assert_equal pages, used_pages
  end
end