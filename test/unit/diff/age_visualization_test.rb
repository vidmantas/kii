require 'test_helper'

class AgeVisualizationTest < Test::Unit::TestCase
  AVR = Kii::Diff::AgeVisualization::Revision
  
  def test_basic_object_tree
    one_day_ago = Time.now - 86400
    two_days_ago = Time.now - 172800
    
    expected = [
      AVR.new("This is", one_day_ago),
      AVR.new(" some pretty old", two_days_ago),
      AVR.new(" text.", nil)
    ]

    revisions = [
      AVR.new("That was some pretty old milk.", two_days_ago),
      AVR.new("This is some pretty old milk.", one_day_ago),
      AVR.new("This is some pretty old text.", nil)
    ]
    
    visualizer = Kii::Diff::AgeVisualization.new(revisions)
    visualizer.compute
    assert_equal expected, visualizer.revOut
  end
end