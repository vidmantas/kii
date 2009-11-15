require "test_helper"

class HtmlTest < ActiveSupport::TestCase
  def test_basic
    assert_equal "Well<del> foo and foo</del><ins> bar</ins> to you.", Kii::Diff::HTML.diff("Well foo and foo to you.", "Well bar to you.")
  end
end