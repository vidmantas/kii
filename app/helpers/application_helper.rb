module ApplicationHelper
  def render_body(body)
    Kii::Markup.new(body).to_html({
      :page_link => proc {|page, title| page_link(page, title) },
      :post_process => proc {|html| auto_link(html) }
    })
  end

  def page_title(*titles, &block)
    @page_title = titles.join(" / ")
    meta = content_tag(:div, block_given? ? capture(&block) : "&nbsp;", :id => "page_meta")
    concat(meta)
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
  
  # See the activity log and page revisions.
  def grouped_revision_log(revisions, columns, &block)
    return if revisions.empty?
    
    first = revisions.first.created_at
    last = revisions.last.created_at
    
    if first.month == last.month && first.year == last.year
      resolution = "day"
      header_format = "%B %d %Y"
      row_format =  proc {|t| t.strftime("%H:%M") }
    elsif first.month != last.month && first.year == last.year
      resolution = "month"
      header_format = "%B %Y"
      row_format = proc {|t| t.strftime("%d").to_i.ordinalize + t.strftime(", %H:%M") }
    else
      resolution = "year"
      header_format = "%Y"
      row_format = proc {|t| t.strftime("%B ") + t.strftime("%d").to_i.ordinalize + t.strftime(", %H:%M") }
    end
    
    grouped_revisions = revisions.group_by {|r| r.created_at.send("at_beginning_of_#{resolution}") }
    
    output = content_tag(:table, :id => "grouped_revision_log") {
      content_tag(:thead) {
        content_tag(:tr) {
          columns.map {|c| content_tag(:th, c )}
        }
      } +
      
      content_tag(:tbody) {
        grouped_revisions.map {|date, revisions|
          content_tag(:tr, :class => "group_header") {
            content_tag(:td, date.strftime(header_format), :colspan => columns.length)
          } +
          revisions.map {|revision|
            timestamp = row_format.call(revision.created_at)
            content_tag(:tr, capture(revision,  timestamp, &block))
          }.join
        }
      }
    }
    
    concat(output)
  end
  
  def polymorphic_discussion_link(discussion)
    link_to discussion.title, (discussion.page_id ? page_discussion_path(discussion.page, discussion) : discussion_path(discussion))
  end
  
  def viewing_revision_in_plain_mode?
    current_page?(page_revision_path(@page, @revision)) || current_page?(page_path(@page))
  end
end
