module ApplicationHelper
  def render_body(body)
    Kii::Markup.new(body, self).to_html
  end

  def page_title(title)
    @page_title = title
  end
  
  def revision_link(page, revision)
    link_to page_timestamp(revision.created_at), page_revision_path(page, revision)
  end
  
  def revision_author_stamp(revision)
    revision.user_id ? link_to(h(revision.user.login), user_path(revision.user)) : revision.remote_ip
  end
end
