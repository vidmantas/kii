require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test "won't create without body" do
    page = Factory.build(:page, :revision_attributes => {:body => nil})
    assert !page.valid?
  end
  
  test "won't update without valid revision data" do
    page = Factory(:page)
    page.revision_attributes = {:body => nil}
    assert !page.valid?
  end
  
  test "incrementing revision number" do
    page = Factory(:page)
    assert_equal 1, page.revisions.last.revision_number
    
    page.revision_attributes = {:body => "updated", :remote_ip => "0.0.0.0", :referrer => "/"}
    page.save
    assert_equal 2, page.revisions.last.revision_number
    
    page.revision_attributes = {:body => "updated, again!", :remote_ip => "0.0.0.0", :referrer => "/"}
    page.save
    assert_equal 3, page.revisions.last.revision_number
  end
  
  test "revision numbers across pages" do
    page_a = Factory(:page, :title => "Page A")
    assert_equal 1, page_a.revisions.last.revision_number
    
    page_b = Factory(:page, :title => "Page B")
    assert_equal 1, page_b.revisions.last.revision_number
  end
  
  test "bumping updated at regardless of there being changes to the page itself" do
    page = Factory(:page)
    was_updated_at = page.updated_at

    page.revision_attributes = {:body => "Yep!", :remote_ip => "0.0.0.0", :referrer => "/"}
    assert page.save
    
    assert_not_equal was_updated_at, page.updated_at
  end
  
  test "restricted names" do
    page = Factory.build(:page, :title => "_")
    assert !page.valid?
    assert page.errors.on("title")
  end
  
  test "save without changes doesn't create revisions" do
    page = Factory(:page)
    assert_no_difference("Revision.count") do
      page.attributes = Factory.build(:page).attributes
      page.save
    end
  end
  
  test "soft destroy" do
    page = Factory(:page)
    
    Factory(:revision, :page => page, :body => "Changed.")
    Factory(:revision, :page => page, :body => "Changed again!")
    Factory(:revision, :page => page, :body => "One last change.")
    
    Factory(:discussion, :page => page)
    Factory(:discussion, :page => page)
    
    assert_difference("Discussion.count", -2) do
      page.soft_destroy
    end
    
    assert_equal 1, page.revisions.count
    assert_equal 1, page.revisions.current.revision_number
    assert page.deleted?
  end
  
  
  test "soft destroy home page" do
    home_page = Page.find_by_permalink!(Kii::CONFIG[:home_page])
    home_page.soft_destroy
    home_page.reload
    assert !home_page.deleted?
  end
  
  test "creating content age diff" do
    page = Factory.build(:page)
    assert_difference("PageContentAgeDiff.count") do
      page.save
    end
  end
  
  test "restoring" do
    page = Factory(:page)
    page.soft_destroy
    page.reload
    
    page.restore
    page.reload
    assert !page.deleted?
    assert_equal 1, page.revisions.count
  end
  
  test "restoring undeleted page" do
    page = Factory(:page)
    page.expects(:update_without_callbacks).never
    page.restore
  end
  
  test "updating content age diff" do
    page = Factory(:page, :revision_attributes => {:body => "hello"})
    assert_equal ["hello"], page.page_content_age_diff.data_as_objects.map(&:text)
    page.revision_attributes = {:body => "hello world", :remote_ip => "0.0.0.0", :referrer => "/"}
    assert page.save
    page.page_content_age_diff.reload
    assert_equal ["hello", " world"], page.page_content_age_diff.data_as_objects.map(&:text)
  end
  
  test "rollback to" do
    page = Factory(:page)
    revision = Factory(:revision, :page => page)
    Factory(:revision, :page => page)
    Factory(:revision, :page => page)
    
    assert_difference("Revision.count", -2) do
      page.rollback_to(revision)
    end
  end
end
