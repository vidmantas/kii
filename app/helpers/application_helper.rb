module ApplicationHelper
  def render_body(body)
    Kii::Markup.new(body, self).to_html
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

  def revision_author_stamp(revision)
    if revision.user_id
      link_to h(revision.user.login), user_path(revision.user)
    else
      link_to revision.remote_ip, ip_path(revision.remote_ip)
    end
  end
end
