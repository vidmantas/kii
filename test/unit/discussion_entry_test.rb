require 'test_helper'

class DiscussionEntryTest < ActiveSupport::TestCase
  test "caching the revision number" do
    # TODO: Make this a sensible test.
    
    page = Factory(:page)
    discussion = page.discussions.new(:title => "That", :discussion_entry_attributes => {:body => "Well, hello there.", :remote_ip => "0.0.0.0", :referrer => "/"})
    assert discussion.save
    assert_equal page.revisions.current.revision_number, discussion.discussion_entries.last.at_revision
    
    another_entry = discussion.discussion_entries.create!(:body => "Another discussion entry", :remote_ip => "0.0.0.0", :referrer => "/")
    assert_equal page.revisions.current.revision_number, discussion.discussion_entries.last.at_revision
    
    page.revision_attributes = {:body => "Moar.", :remote_ip => "0.0.0.0", :referrer => "/"}
    page.save!
    
    last_entry = discussion.discussion_entries.create!(:body => "Another discussion entry", :remote_ip => "0.0.0.0", :referrer => "/")
    assert_equal page.revisions.current.revision_number, discussion.discussion_entries.last.at_revision
    assert_not_equal page.revisions.current.revision_number, another_entry.at_revision
  end
end
