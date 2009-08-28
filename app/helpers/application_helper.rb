module ApplicationHelper
  def render_body(body)
    Kii::Markup.new(body).to_html
  end

  def page_title(title)
    @page_title = title
  end

  # Redlinks or bluelinks to a page. Since the parser allows [[page title||Custom title]],
  # the 2nd argument can be a custom title that will be rendered instead of the title in the
  # database.
  def page_link(page, title = nil)
    options = {}
    
    if page.deleted?
      options[:class] = "pagelink void"
      options[:href] = "/" + page.permalink
    else
      options[:class] = "pagelink exists"
      options[:href] = "/" + page.permalink
    end
    
    options[:href].force_encoding("UTF-8") if options[:href].respond_to?(:force_encoding)

    link_to(title || h(page.title), page_path(page), options)
  end

  # The active_record_instance has to have a user_id, belongs_to :user and a remote_ip column.
  def author_link(active_record_instance)
    if active_record_instance.user_id
      link_to h(active_record_instance.user.login), user_path(active_record_instance.user)
    else
      link_to active_record_instance.remote_ip, ip_path(active_record_instance.remote_ip)
    end
  end
end
