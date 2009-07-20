module ApplicationHelper
  def render_body(body)
    Kii::Markup.new(body, self).to_html
  end

  def page_title(title)
    @page_title = title
  end

  def revision_author_stamp(revision)
    if revision.user_id
      link_to h(revision.user.login), user_path(revision.user)
    else
      link_to revision.remote_ip, ip_path(revision.remote_ip)
    end
  end
end
