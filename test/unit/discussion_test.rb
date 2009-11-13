require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  test "requiring a discussion entry" do
    @discussion = Factory.build(:discussion)
    @discussion.discussion_entry_attributes = {}
    assert !@discussion.valid?
    
    @discussion = Factory(:discussion)
    @discussion = Discussion.find(@discussion.id) # reload won't clear all instance vars
    assert !@discussion.valid?
    
    @discussion.reload
    @discussion.discussion_entry_attributes = {}
    assert !@discussion.valid?
    
    @discussion.reload
    @discussion.discussion_entry_attributes = {:body => "Yeah!", :referrer => "/", :remote_ip => "0.0.0.0"}
    assert @discussion.valid?
  end
  
  test "grouped by user only contains each discussion once" do
    @user = Factory(:user)
    @discussion = Factory(:discussion, :user => @user)
    
    # A bunch of discussion going on
    Factory(:discussion_entry, :discussion => @discussion, :user => @user)
    Factory(:discussion_entry, :discussion => @discussion)
    Factory(:discussion_entry, :discussion => @discussion)
    Factory(:discussion_entry, :discussion => @discussion, :user => @user)
    
    assert_equal [@discussion], Discussion.grouped_by_entries.by_user(@user)
  end
  
  test "by_ip does not include discussion entries with an user_id" do
    @user = Factory(:user)
    
    @discussion = Factory(:discussion, :user => @user)
    Factory(:discussion_entry, :discussion => @discussion, :remote_ip => "1.2.3.4")
    
    assert_equal 0, Discussion.grouped_by_entries.by_ip("4.3.2.1").count
    assert_equal 1, Discussion.grouped_by_entries.by_ip("1.2.3.4").count
  end
end
