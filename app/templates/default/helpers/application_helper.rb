module ApplicationHelper
  def last_updated_at(page)
    %{Last updated #{page_timestamp(page.updated_at)}}
  end
  
  def page_timestamp(time)
    "#{datestamp(time)}, #{timestamp(time)}"
  end
  
  # July 12 2009
  def datestamp(time)
    time.strftime("%B %d %Y")
  end
  
  # 23:15
  def timestamp(time)
    time.strftime("%H:%M")
  end
  
  def template_script(script)
    "/templates/#{Kii::CONFIG[:template]}/javascripts/#{script}"
  end
end