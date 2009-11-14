require 'test_helper'

class RedclothTest < ActiveSupport::TestCase
  def setup
    @helper = Object.new
  end
  
  test "page links being parsed" do
    expected = "<p>Here is <strong>textile</strong> and /page links/</p>"
    @helper.class_eval {
      define_method(:page_link) {|page, title| "/#{title}/" }
    }
    
    assert_equal expected, Kii::Markup::Languages::Redcloth.new("Here is *textile* and [[page links]]", @helper).to_html
  end
end