require 'test_helper'

# TODO: Move (some of the) tests related to page link parsing from markup tests to this test.
class PreprocessorTest < ActiveSupport::TestCase
  def setup
    @helper = Object.new
  end
  
  test "parsing" do
    markup = "Some [[pages]] and [[more pages]] here."
    @preprocessor = Kii::Markup::Preprocessor.new(markup, @helper)
    @helper.expects(:page_link).times(2).returns("xxx")
    assert_equal "Some xxx and xxx here.", @preprocessor.parse(markup)
  end
  
  test "finding pages from the database" do
    markup = "[[a few]] foo bar [[page links]]"
    p = Page.create!(:title => "a few", :revision_attributes => {:body => "Something!", :remote_ip => "0.0.0.0", :referrer => "/"})
    @preprocessor = Kii::Markup::Preprocessor.new(markup, @helper)

    assert_equal [p], @preprocessor.instance_variable_get("@linked_pages")
  end
  
  test "lowercased match" do
    Page.create!(:title => "Hullo", :revision_attributes => {:body => "Something!", :remote_ip => "0.0.0.0", :referrer => "/"})
    markup = "Linking lowercased: [[hullo]]."
    
    @helper.class_eval {
      define_method(:page_link) {|page, title| "#{title} - #{page.title} - #{page.new_record?}" }
    }
    
    @preprocessor = Kii::Markup::Preprocessor.new(markup, @helper)
    assert_equal "Linking lowercased: hullo - Hullo - false.", @preprocessor.parse(markup)
  end
  
  test "custom titles" do
    markup = "[[link|Custom title]]"
    
    @helper.class_eval {
      define_method(:page_link) {|page, title| title }
    }
    
    @preprocessor = Kii::Markup::Preprocessor.new(markup, @helper)
    assert_equal "Custom title", @preprocessor.parse(markup)
  end
end
