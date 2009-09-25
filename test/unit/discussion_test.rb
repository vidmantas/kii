require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  test "validity of factory discussion" do
    assert new_discussion.valid?
  end
  
  test "requiring a discussion entry" do
    @discussion = new_discussion
    @discussion.discussion_entry_attributes = {}
    assert !@discussion.valid?
    
    @discussion = create_discussion
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
    @discussion = discussions(:sandbox_a)
    @discussion.discussion_entries.create!(:body => "A second", :referrer => "/", :remote_ip => "0.0.0.0")
    assert_equal [discussions(:sandbox_a)], Discussion.grouped_by_entries.by_user(users(:admin))
  end
  
  test "by_ip does not include discussion entries with an user_id" do
    @discussion = create_discussion(:discussion_entry_attributes => {:body => "Hi", :referrer => "/", :remote_ip => "1.2.3.4", :user => users(:admin)})
    @discussion.discussion_entries.create!(:body => "A second", :referrer => "/", :remote_ip => "4.3.2.1")
    assert Discussion.grouped_by_entries.by_ip("1.2.3.4").empty?
    assert_equal 1, Discussion.grouped_by_entries.by_ip("4.3.2.1").count
  end
  
  private
  
  def new_discussion(attrs = {})
    attrs.reverse_merge!(:title => "Is it true?", :discussion_entry_attributes => {:body => "Is it??", :referrer => "/", :remote_ip => "0.0.0.0"}, :page => pages(:sandbox))
    Discussion.new(attrs)
  end
  
  def create_discussion(attrs = {})
    d = new_discussion(attrs)
    d.save
    return d
  end
end
