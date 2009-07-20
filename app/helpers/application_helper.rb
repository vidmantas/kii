module ApplicationHelper
  def render_body(body)
    Kii::Markup.new(body, self).to_html
  end

  def page_title(title)
    @page_title = title
  end
end
