module SidebarHelper
  def tabs(entries)
    content_tag(:ul, entries.map {|title, url, current|
      if title.is_a?(Proc)
        title.call
      else
        klass = []
        klass << "current" if current || current_page?(url)
        content_tag(:li, link_to(title, url), :class => klass.join(" "))
      end
    }.join, :id => "tabs", :class => "simple")
  end
  
  def sidebar_visible?
    !@content_for_sidebar.blank?
  end
end