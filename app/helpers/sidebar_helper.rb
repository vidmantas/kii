module SidebarHelper
  def tab(title, url, current = nil)
    content_tag(:li, link_to(title, url), :class => (current.nil? ? current_page?(url) : current) && "current")
  end
  
  def sidebar_visible?
    !@content_for_sidebar.blank?
  end
end