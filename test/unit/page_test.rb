require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test "validity of factory page" do
    assert new_page.valid?
  end
  
  test "won't create without body" do
    page = new_page(:revision_attributes => {:body => nil, :remote_ip => "0.0.0.0", :referrer => "/"})
    assert !page.valid?
  end
  
  test "won't update without valid revision data" do
    page = create_page
    page.revision_attributes = {:body => nil}
    assert !page.valid?
  end
  
  test "incrementing revision number" do
    page = create_page
    assert_equal 1, page.revisions.last.revision_number
    
    page.revision_attributes = {:body => "updated", :remote_ip => "0.0.0.0", :referrer => "/"}
    page.save
    assert_equal 2, page.revisions.last.revision_number
    
    page.revision_attributes = {:body => "updated, again!", :remote_ip => "0.0.0.0", :referrer => "/"}
    page.current_revision_id = page.revisions.last.id
    page.save
    assert_equal 3, page.revisions.last.revision_number
  end
  
  test "revision numbers across pages" do
    page_a = create_page(:title => "Page A")
    assert_equal 1, page_a.revisions.last.revision_number
    
    page_b = create_page(:title => "Page B")
    assert_equal 1, page_b.revisions.last.revision_number
  end
  
  test "bumping updated at regardless of there being changes to the page itself" do
    page = pages(:home)
    was_updated_at = page.updated_at

    page.revision_attributes = {:body => "Yep!", :remote_ip => "0.0.0.0", :referrer => "/"}
    assert page.save
    
    assert_not_equal was_updated_at, page.updated_at
  end
  
  test "restricted names" do
    page = new_page(:title => "_")
    assert !page.valid?
    assert page.errors.on("title")
  end
  
  test "save without changes doesn't create revisions" do
    
    assert_no_difference("Revision.count") do
      page = pages(:sandbox)
      page.revision_attributes = {:body => page.revisions.current.body, :remote_ip => "0.0.0.0", :referrer => "/"}
      page.save
    end
  end
  
  test "soft destroy" do
    page = pages(:sandbox)
    assert page.revisions.count > 1 # testing fixtures ftl.. Oh well.
    
    page.soft_destroy
    assert_equal 1, page.revisions.count
    assert_equal 1, page.revisions.current.revision_number
    assert page.deleted?
  end
  
  test "creating content age diff" do
    page = new_page
    assert_difference("PageContentAgeDiff.count") do
      page.save
    end
  end
  
  test "updating content age diff" do
    page = create_page
    assert_equal ["ai"], page.page_content_age_diff.data_as_objects.map(&:text)
    page.revision_attributes = {:body => "ai wtf", :remote_ip => "0.0.0.0", :referrer => "/"}
    assert page.save
    page.page_content_age_diff.reload
    assert_equal ["ai", " wtf"], page.page_content_age_diff.data_as_objects.map(&:text)
  end
  
  test "rollback to" do
    assert_difference("Revision.count", -2) do
      pages(:sandbox).rollback_to(revisions(:sandbox_b))
    end
  end
  
  def new_page(attrs = {})
    Page.new(attrs.reverse_merge!(:title => "A new page!", :revision_attributes => {:body => "ai", :remote_ip => "0.0.0.0", :referrer => "/"}))
  end
  
  def create_page(attrs = {})
    page = new_page(attrs)
    page.save
    return page
  end
end
