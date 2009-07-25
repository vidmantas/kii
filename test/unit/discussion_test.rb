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
    @discussion.discussion_entry_attributes = {:body => "Yeah!"}
    assert @discussion.valid?
  end
  
  private
  
  def new_discussion(attrs = {})
    attrs.reverse_merge!(:title => "Is it true?", :discussion_entry_attributes => {:body => "Is it??"}, :page => pages(:sandbox))
    Discussion.new(attrs)
  end
  
  def create_discussion(attrs = {})
    d = new_discussion(attrs)
    d.save
    return d
  end
end
