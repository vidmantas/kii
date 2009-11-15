require 'test_helper'

class MarkupIntegrationTest < ActiveSupport::TestCase
  FIXTURES = YAML.load_file("#{Rails.root}/test/unit/markup/markup_integration_fixtures.yml")
  
  FIXTURES.each do |fixture|
    test fixture["title"] do
      output = Kii::Markup.new(fixture["in"].strip).to_html { "" }
      assert_equal fixture["out"].strip,
        output,
        "* #{fixture["title"]} failed *\n\n* Input *\n#{fixture["in"]}\n\n* Output *\n#{output}\n"
    end
  end
end
