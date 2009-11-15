module ApplicationHelper
  def render_body(markup)
    html = Kii::Markup.new(markup).to_html {|page, title| page_link(page, title) }
    auto_link(html)
  end

  def render_body_with_references(markup)
    parser = Kii::Markup.new(markup)
    html = parser.to_html {|page, title| page_link(page, title)}
    
    references = parser.references.map {|r| auto_link(Kii::Markup.new(r).to_html_without_paragraphs) }
    if !references.empty?
      content_for(:content_bottom) { render :partial => "pages/references", :locals => {:references => references} }
    end
    
    return auto_link(html)
  end

  def page_title(*titles, &block)
    @page_title = titles.join(" / ")
    meta = content_tag(:div, block_given? ? capture(&block) : "", :id => "page_meta")
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
  
  def grouped_record_log(records, columns, timestamp_column = :created_at, &block)
    if records.empty?
      concat content_tag(:p, "No entries", :class => "empty_grouped_record_log")
      return
    end
    
    first = records.first[timestamp_column]
    last = records.last[timestamp_column]
    
    if first.day == last.day && first.month == last.month && first.year == last.year
      resolution = "hour"
      header_format = "%H:%M"
      row_format = proc {|t| t.strftime("%H:%M") }
    elsif first.month == last.month && first.year == last.year
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
    
    grouped_records = records.group_by {|r| r[timestamp_column].send("at_beginning_of_#{resolution}") }
    
    output = content_tag(:table, :id => "grouped_record_log") {
      content_tag(:thead) {
        content_tag(:tr) {
          columns.map {|c| content_tag(:th, c )}
        }
      } +
      
      content_tag(:tbody) {
        grouped_records.map {|date, records|
          content_tag(:tr, :class => "group_header") {
            content_tag(:td, date.strftime(header_format), :colspan => columns.length)
          } +
          records.map {|record|
            timestamp = row_format.call(record[timestamp_column])
            content_tag(:tr, capture(record,  timestamp, &block))
          }.join
        }
      }
    }
    
    concat(output)
  end
  
  def flashes
    flash.map {|type, msg| content_tag(:div, msg, :class => "flash", :id => "flash_#{type}")}
  end
  
  def tab(title, url, current = nil)
    content_tag(:li, link_to(title, url), :class => (current.nil? ? current_page?(url) : current) && "current")
  end
  
  def logo_image
    site_logo = Pathname.glob(Rails.root + "public/images/site_logo.*")[0]
    
    if site_logo
      site_logo.basename.to_s
    else
      "logo.png"
    end
  end
end
