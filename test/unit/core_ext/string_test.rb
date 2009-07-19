# encoding: utf-8
require 'test_helper'

class StringTest < ActiveSupport::TestCase
  test "to_permalink" do
    assert_equal "Øystein_Sunde_&_Bananene", "Øystein Sunde & Bananene".to_permalink
  end
  
  test "from_permalink" do
    assert_equal "Øystein Sunde & Bananene", "Øystein_Sunde_&_Bananene".from_permalink
  end
  
  test "upcase first letter" do
    assert_equal "Foo", "foo".upcase_first_letter
    assert_equal "FOO", "fOO".upcase_first_letter
    assert_equal "Foo bar", "foo bar".upcase_first_letter
  end
end
