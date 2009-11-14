require 'test_helper'

class DefaultMarkupTest < ActiveSupport::TestCase
  FIXTURES = YAML.load_file("#{Rails.root}/test/unit/markup/default_markup_fixtures.yml")
  
  MOCK_HELPER = Object.new
  MOCK_HELPER.class_eval {
    define_method(:page_link) {|*args| "" }
    define_method(:auto_link) {|text| text  }
  }
  
  FIXTURES.each do |fixture|
    test fixture["title"] do
      output = Kii::Markup::Languages::Default.new(fixture["in"].strip, MOCK_HELPER).to_html
      assert_equal fixture["out"].strip,
        output,
        "* #{fixture["title"]} failed *\n\n* Input *\n#{fixture["in"]}\n\n* Output *\n#{output}\n"
    end
  end
end
