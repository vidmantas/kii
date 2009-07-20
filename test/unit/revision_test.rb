require 'test_helper'

class RevisionTest < ActiveSupport::TestCase
  test "incrementing revision number" do
    # This is currently tested in the page unit test.
  end
  
  test "destroying removes all consecutive revisions" do
    page = pages(:sandbox)
    older_revision = revisions(:sandbox_c)
    assert_not_equal older_revision, page.revisions.current

    assert_difference("Revision.count", -2) do
      older_revision.destroy
    end
    
    assert_equal revisions(:sandbox_b), page.revisions.current
  end
end
