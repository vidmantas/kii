module ActivitiesHelper
  def render_group_header(type, time)
    case type
    when "day"
      time.strftime("%B %d %Y")
    when "month"
      time.strftime("%B %Y")
    when "year"
      time.strftime("%Y")
    end
  end
  
  def render_activity_timestamp(type, time)
    case type
    when "day"
      time.strftime("%H:%M")
    when "month"
      time.strftime("%d").to_i.ordinalize + time.strftime(", %H:%M")
    when "year"
      time.strftime("%B ") + time.strftime("%d").to_i.ordinalize + time.strftime(", %H:%M")
    end
  end
end