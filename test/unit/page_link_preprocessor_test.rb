require 'test_helper'

# TODO: Move (some of the) tests related to page link parsing from markup tests to this test.
class PageLinkPreprocessorTest < ActiveSupport::TestCase
  test "finding pages from the database" do
    markup = "[[a few]] foo bar [[page links]]"
    p = Page.create!(:title => "a few", :revision_attributes => {:body => "Something!", :remote_ip => "0.0.0.0", :referrer => "/"})
    @preprocessor = Kii::PageLinkPreprocessor.new(markup)

    assert_equal [p], @preprocessor.instance_variable_get("@linked_pages")
  end
end
