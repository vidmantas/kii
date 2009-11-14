module ApplicationHelper
  def clever_timestamp(time)
    if time.today?
      "#{shorter_time_ago_in_words(time)} ago"
    else
      datetimestamp(time)
    end
  end
  
  def datetimestamp(time)
    "#{datestamp(time)}, #{timestamp(time)}"
  end
  
  # July 12 2009
  def datestamp(time)
    time.strftime("%b. %d %Y")
  end
  
  # 23:15
  def timestamp(time)
    time.strftime("%H:%M")
  end
  
  # 5s instead of "5 seconds"
  def shorter_time_ago_in_words(time)
    distance = Time.now.to_i - time.to_i
    case distance
    when 0..59
      "#{distance}s"
    when 60..3599
      "#{distance / 60}m"
    when 3600..86399
      "#{distance / 60 / 60}h"
    else
      "#{distance / 60 / 60 / 24}d"
    end
  end
  
  def template_script(script)
    "/templates/#{Configuration[:template]}/javascripts/#{script}"
  end
end